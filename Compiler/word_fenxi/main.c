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

// -------------------- ȫ�ֶ��� --------------------
enum TokenType { KEYWORD = 0, IDENT = 1, NUMBER = 2, OPERATOR = 3, DELIMITER = 4 };

// �ؼ��ֱ�
const char *keywords[] = {"if", "then", "else", "endif", "while", "do", NULL};

// ������������ȼ�����
const char *operators[] = {
    ":=", "<=", ">=", "+", "-", "*", "/", "=", "<", ">", NULL
};

// ���޷���
const char *delimiters[] = {";", "(", ")", "{", "}", NULL};

// ��ʶ������̬��չ��
typedef struct { 
    char **entries; 
    int count; 
} IdTable;
IdTable idTable = {NULL, 0};

// ��������̬��չ��
typedef struct { 
    int *values; 
    int count; 
} NumTable;
NumTable numTable = {NULL, 0};

// Token���У���̬��չ��
typedef struct { 
    int type; 
    int attr; 
} Token;
Token *tokens = NULL;
int tokenCount = 0;

// �����
typedef struct {
    int line;
    int column;
    const char *message;
    char *lexeme;
} LexError;
LexError *errors = NULL;
int errorCount = 0;

// ����׷��
int currentLine = 1;
int currentColumn = 1;

// -------------------- �������� --------------------
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
        fprintf(stderr, "�ʷ����� Line %d, Column %d: %s '%s'\n",
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


// -------------------- �ʷ��������� --------------------
void lexer(FILE *input) {
    char c;  // ��ǰ�ַ�

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
            ungetc(c, input);  // ��������ȡ���ַ�

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
                add_error(currentLine, startColumn, "��Ч��ʶ��", buffer);
            } else {
                buffer[idx] = '\0';
                int num = atoi(buffer);
                int num_idx = add_number(num);
                tokens = realloc(tokens, (tokenCount + 1) * sizeof(Token));
                tokens[tokenCount++] = (Token){NUMBER, num_idx};
            }
            ungetc(c, input);  // ��������ȡ���ַ�
        } 
        else {
            // ����˫�ַ�
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
            // �����ַ�
            // ����ע��
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
                        add_error(startLine, startColumn, "ע��δ�պ�", "/*");
                    }
                    continue;  
                }
                ungetc(next, input); 
            }
            //�����������ַ����

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
                add_error(currentLine, currentColumn, "��Ч�ַ�", buf);
                currentColumn++;
            }
        }
    }
}

// -------------------- �ļ���� --------------------
void write_tables() {
    // д��ʶ����
    FILE *id_file = fopen("identifiers.txt", "w");
    for (int i = 0; i < idTable.count; i++) {
        fprintf(id_file, "%d: %s\n", i, idTable.entries[i]);
    }
    fclose(id_file);

    // д������
    FILE *num_file = fopen("constants.txt", "w");
    for (int i = 0; i < numTable.count; i++) {
        fprintf(num_file, "%d: %d\n", i, numTable.values[i]);
    }
    fclose(num_file);

    // дToken����
    FILE *token_file = fopen("tokens.txt", "w");
    for (int i = 0; i < tokenCount; i++) {
        fprintf(token_file, "<%d,%d> ", tokens[i].type, tokens[i].attr);
    }
    fclose(token_file);

    // д�ؼ��ֱ��������ͽ��޷���һ���ļ�
    FILE *syntax_file = fopen("syntax_tables.txt", "w");

    // д�ؼ��ֱ�
    fprintf(syntax_file, "Keywords(TokenType = 0):\n");
    for (int i = 0; keywords[i] != NULL; i++) {
        fprintf(syntax_file, "%d: %s\n", i, keywords[i]);
    }

    // д�������
    fprintf(syntax_file, "\nOperators(TokenType = 3):\n");
    for (int i = 0; operators[i] != NULL; i++) {
        fprintf(syntax_file, "%d: %s\n", i, operators[i]);
    }

    // д���޷���
    fprintf(syntax_file, "\nDelimiters(TokenType = 4):\n");
    for (int i = 0; delimiters[i] != NULL; i++) {
        fprintf(syntax_file, "%d: %s\n", i, delimiters[i]);
    }

    fclose(syntax_file);
}

// -------------------- ������ --------------------
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