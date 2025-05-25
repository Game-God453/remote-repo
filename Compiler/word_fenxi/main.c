#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

char* strndup(const char *s, size_t n) {
    char *p = memchr(s, '\0', n);
    size_t len = (p != NULL) ? (size_t)(p - s) : n;
    char *dup = malloc(len + 1);
    if (dup != NULL) {
        memcpy(dup, s, len);
        dup[len] = '\0';
    }
    return dup;
}

// -------------------- 全局定义 --------------------
enum TokenType { KEYWORD = 0, IDENT = 1, NUMBER = 2, OPERATOR = 3, DELIMITER = 4 };

// 关键字表
const char *keywords[] = {"if", "then", "else", "endif", "while", "do", NULL};

// 运算符表（按优先级排序）
const char *operators[] = {
    ":=", "<=", ">=", "+", "-", "*", "/", "=", "<", ">", NULL
};

// 界限符表
const char *delimiters[] = {";", "(", ")", "{", "}", NULL};

// 标识符表（动态扩展）
typedef struct { 
    char **entries; 
    int count; 
} IdTable;
IdTable idTable = {NULL, 0};

// 常数表（动态扩展）
typedef struct { 
    int *values; 
    int count; 
} NumTable;
NumTable numTable = {NULL, 0};

// Token序列（动态扩展）
typedef struct { 
    int type; 
    int attr; 
} Token;
Token *tokens = NULL;
int tokenCount = 0;

// 错误表
typedef struct {
    int line;
    int column;
    const char *message;
    char *lexeme;
} LexError;
LexError *errors = NULL;
int errorCount = 0;

// 行列追踪
int currentLine = 1;
int currentColumn = 1;

// -------------------- 辅助函数 --------------------
void add_error(int line, int column, const char *message, const char *lexeme) {
    errors = realloc(errors, (errorCount + 1) * sizeof(LexError));
    errors[errorCount].line = line;
    errors[errorCount].column = column;
    errors[errorCount].message = message;
    errors[errorCount].lexeme = strdup(lexeme);
    errorCount++;
}

void print_errors() {
    for (int i = 0; i < errorCount; i++) {
        fprintf(stderr, "词法错误！ Line %d, Column %d: %s '%s'\n",
                errors[i].line, errors[i].column, errors[i].message, errors[i].lexeme);
        free(errors[i].lexeme);
    }
    free(errors);
}

int find_index(const char **table, const char *str) {
    for (int i = 0; table[i] != NULL; i++) {
        if (strcmp(table[i], str) == 0) return i;
    }
    return -1;
}

int add_identifier(const char *name) {
    for (int i = 0; i < idTable.count; i++) {
        if (strcmp(idTable.entries[i], name) == 0) return i;
    }
    idTable.entries = realloc(idTable.entries, (idTable.count + 1) * sizeof(char *));
    idTable.entries[idTable.count] = strdup(name);
    return idTable.count++;
}

int add_number(int num) {
    for (int i = 0; i < numTable.count; i++) {
        if (numTable.values[i] == num) return i;
    }
    numTable.values = realloc(numTable.values, (numTable.count + 1) * sizeof(int));
    numTable.values[numTable.count] = num;
    return numTable.count++;
}


// -------------------- 词法分析核心 --------------------
void lexer(FILE *input) {
    char c;  // 当前字符

    while ((c = fgetc(input)) != EOF && c != '#') {

        if (c == '\n') {
            currentLine++;
            currentColumn = 1;
            continue;
        }

        if (isspace(c)) {
            currentColumn++;
            continue;
        }

        if (isalpha(c)) {
            int startColumn = currentColumn;
            char buffer[256];
            int idx = 0;
            do {
                buffer[idx++] = c;
                c = fgetc(input);
                currentColumn++;
            } while (isalnum(c));
            buffer[idx] = '\0';
            ungetc(c, input);  // 回退最后读取的字符

            int key_idx = find_index(keywords, buffer);
            if (key_idx != -1) {
                tokens = realloc(tokens, (tokenCount + 1) * sizeof(Token));
                tokens[tokenCount++] = (Token){KEYWORD, key_idx};
            } else {
                int id_idx = add_identifier(buffer);
                tokens = realloc(tokens, (tokenCount + 1) * sizeof(Token));
                tokens[tokenCount++] = (Token){IDENT, id_idx};
            }
        } 
        else if (isdigit(c)) {
            int startColumn = currentColumn;
            char buffer[256];
            int idx = 0;
            do {
                buffer[idx++] = c;
                c = fgetc(input);
                currentColumn++;
            } while (isdigit(c));
            if (isalpha(c)) {
                do {
                    buffer[idx++] = c;
                    c = fgetc(input);
                    currentColumn++;
                } while (isalnum(c));
                buffer[idx] = '\0';
                add_error(currentLine, startColumn, "无效标识符", buffer);
            } else {
                buffer[idx] = '\0';
                int num = atoi(buffer);
                int num_idx = add_number(num);
                tokens = realloc(tokens, (tokenCount + 1) * sizeof(Token));
                tokens[tokenCount++] = (Token){NUMBER, num_idx};
            }
            ungetc(c, input);  // 回退最后读取的字符
        } 
        else {
            // 处理双字符
            if(c == ':' || c == '<' || c == '>') {
                char buf[3] = {c, fgetc(input), '\0'};
                currentColumn++;
                if (find_index(operators, buf) != -1) {
                    tokens = realloc(tokens, (tokenCount + 1) * sizeof(Token));
                    tokens[tokenCount++] = (Token){OPERATOR, find_index(operators, buf)};
                    currentColumn++;
                    continue;
                } 
                else {
                    ungetc(buf[1], input);
                    currentColumn--;
                }
            }
            // 处理单字符
            // 处理注释
            if(c == '/') {
                char next = fgetc(input);
                int startColumn = currentColumn;
                int startLine = currentLine;
                if(next == '/') {
                    do {
                        c = fgetc(input);
                    } while (c != '\n');
                    currentLine++;
                    currentColumn = 1;
                    continue;
                }
                else if(next == '*') {
                    do {
                        c = fgetc(input);
                        currentColumn++;
                        if(c == '*') {
                            c = fgetc(input);
                            currentColumn++;
                            if(c == '/') {
                                break;
                            }
                        }
                        if(c == '\n')
                        {
                            currentLine++;
                            currentColumn = 0;
                        }
                    } while (c != '#');
                    if (c == '#') {
                        add_error(startLine, startColumn, "注释未闭合", "/*");
                    }
                    continue;  
                }
                ungetc(next, input); 
            }
            //处理其它单字符情况

            char buf[2] = {c, '\0'};
            if(find_index(operators, buf) != -1) {
                tokens = realloc(tokens, (tokenCount + 1) * sizeof(Token));
                tokens[tokenCount++] = (Token){OPERATOR, find_index(operators, buf)};
                currentColumn++;
            }
            else if(find_index(delimiters, buf) != -1) {
                tokens = realloc(tokens, (tokenCount + 1) * sizeof(Token));
                tokens[tokenCount++] = (Token){DELIMITER, find_index(delimiters, buf)};
                currentColumn++;
            }
            else {
                add_error(currentLine, currentColumn, "无效字符", buf);
                currentColumn++;
            }
        }
    }
}

// -------------------- 文件输出 --------------------
void write_tables() {
    // 写标识符表
    FILE *id_file = fopen("identifiers.txt", "w");
    for (int i = 0; i < idTable.count; i++) {
        fprintf(id_file, "%d: %s\n", i, idTable.entries[i]);
    }
    fclose(id_file);

    // 写常数表
    FILE *num_file = fopen("constants.txt", "w");
    for (int i = 0; i < numTable.count; i++) {
        fprintf(num_file, "%d: %d\n", i, numTable.values[i]);
    }
    fclose(num_file);

    // 写Token序列
    FILE *token_file = fopen("tokens.txt", "w");
    for (int i = 0; i < tokenCount; i++) {
        fprintf(token_file, "<%d,%d> ", tokens[i].type, tokens[i].attr);
    }
    fclose(token_file);

    // 写关键字表、运算符表和界限符表到一个文件
    FILE *syntax_file = fopen("syntax_tables.txt", "w");

    // 写关键字表
    fprintf(syntax_file, "Keywords(TokenType = 0):\n");
    for (int i = 0; keywords[i] != NULL; i++) {
        fprintf(syntax_file, "%d: %s\n", i, keywords[i]);
    }

    // 写运算符表
    fprintf(syntax_file, "\nOperators(TokenType = 3):\n");
    for (int i = 0; operators[i] != NULL; i++) {
        fprintf(syntax_file, "%d: %s\n", i, operators[i]);
    }

    // 写界限符表
    fprintf(syntax_file, "\nDelimiters(TokenType = 4):\n");
    for (int i = 0; delimiters[i] != NULL; i++) {
        fprintf(syntax_file, "%d: %s\n", i, delimiters[i]);
    }

    fclose(syntax_file);
}

// -------------------- 主程序 --------------------
int main(int argc, char *argv[]) {
    FILE *input = fopen("../input.mini", "r");
    if (!input) {
        fprintf(stderr, "Error: File 'input.mini' not found in current directory.\n");
        return 1;
    }

    lexer(input);

    if (errorCount > 0) {
        print_errors();
    } else {
        write_tables();
    }

    for (int i = 0; i < idTable.count; i++) free(idTable.entries[i]);
    free(idTable.entries);
    free(numTable.values);
    free(tokens);

    return 0;
}