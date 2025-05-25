import re

class Token:
    def __init__(self, type, attribute):
        self.type = type
        self.attribute = attribute

    def __repr__(self):
        return f"<{self.type}, {self.attribute}>"

# Token types
KEYWORD = 0
IDENT = 1
NUMBER = 2
OPERATOR = 3
DELIMITER = 4

class ASTNode:
    def __init__(self, node_type, children=None, value=None):
        self.node_type = node_type
        self.children = children if children else []
        self.value = value

    def __repr__(self):
        return f"{self.node_type}: {self.value if self.value is not None else ''}"

class Parser:
    def __init__(self, tokens, keywords, identifiers, numbers, operators, delimiters):
        self.tokens = tokens
        self.keywords = keywords
        self.identifiers = identifiers
        self.numbers = numbers
        self.operators = operators
        self.delimiters = delimiters
        self.current_token_index = 0
        self.current_token = None
        self.errors = []
        self.advance()

    def advance(self):
        if self.current_token_index < len(self.tokens):
            self.current_token = self.tokens[self.current_token_index]
            self.current_token_index += 1
        else:
            self.current_token = None  # End of input
        #print(f"Advanced to token: {self.current_token}") #Commented out for cleaner output

    def consume(self, expected_type, expected_attribute=None):
        #print(f"Attempting to consume: type={expected_type}, attribute={expected_attribute}, current_token={self.current_token}") #Commented out for cleaner output
        if self.current_token and self.current_token.type == expected_type and (expected_attribute is None or self.current_token.attribute == expected_attribute):
            self.advance()
            #print("Consume successful") #Commented out for cleaner output
            return True
        else:
            if self.current_token:
                self.error(f"Expected type {expected_type}, attribute {expected_attribute}, but got {self.current_token}")
            else:
                self.error(f"Expected type {expected_type}, attribute {expected_attribute}, but got end of input")
            #print("Consume failed") #Commented out for cleaner output
            return False

    def error(self, message):
        self.errors.append(f"Error at token {self.current_token_index}: {message}")

    def parse(self):
        return self.parse_program()

    def parse_program(self):
        #print("Parsing program") #Commented out for cleaner output
        statements = []
        while self.current_token:
            statement = self.parse_statement()
            if statement:
                statements.append(statement)
            else:
                break  # Exit loop if parse_statement fails
        #print("Program parsed") #Commented out for cleaner output
        return ASTNode("program", statements)

    def parse_statement(self, expecting_else=False):
        #print(f"Parsing statement, expecting_else={expecting_else}, current_token={self.current_token}") #Commented out for cleaner output
        if self.current_token is None:
            return None

        if self.current_token.type == IDENT:
            return self.parse_assignment_statement()
        elif self.current_token.type == KEYWORD:
            if self.keywords[self.current_token.attribute] == "if":
                return self.parse_if_statement()
            elif self.keywords[self.current_token.attribute] == "while":
                return self.parse_while_statement()
            elif self.keywords[self.current_token.attribute] == "else" and expecting_else:
                return None  # Signal to the parent that we've found the else
            else:
                self.error("Invalid keyword")
                self.advance()
                return None
        elif self.current_token.type == DELIMITER and self.delimiters[self.current_token.attribute] == "{":
            return self.parse_block()
        else:
            self.error("Invalid statement start")
            self.advance()  # Skip the offending token
            return None

    def parse_assignment_statement(self):
        #print("Parsing assignment statement") #Commented out for cleaner output
        if self.current_token.type == IDENT:
            identifier_index = self.current_token.attribute
            self.consume(IDENT)
            if self.current_token and self.current_token.type == OPERATOR and self.operators[self.current_token.attribute] == "=":
                self.consume(OPERATOR, self.operators.index("="))
                expression = self.parse_expression()
                if expression:
                    if self.current_token and self.current_token.type == DELIMITER and self.delimiters[self.current_token.attribute] == ";":
                        self.consume(DELIMITER, self.delimiters.index(";"))
                        return ASTNode("assignment_statement", [ASTNode("identifier", value=self.identifiers[identifier_index]), expression])
                    else:
                        self.error("Missing semicolon at end of assignment")
                        return None
                else:
                    self.error("Invalid expression in assignment")
                    return None
            else:
                self.error("Missing assignment operator")
                return None
        else:
            self.error("Assignment statement must start with an identifier")
            return None

    def parse_if_statement(self):
        #print("Parsing if statement") #Commented out for cleaner output
        if self.consume(KEYWORD, self.keywords.index("if")):
            condition = self.parse_condition()
            if condition:
                if self.consume(KEYWORD, self.keywords.index("then")):
                    then_block = self.parse_block()
                    if not then_block:
                        self.error("Missing 'then' block")
                        return None

                    else_block = None
                    if self.current_token and self.keywords[self.current_token.attribute] == "else":
                        self.consume(KEYWORD, self.keywords.index("else"))
                        else_block = self.parse_block()
                        if not else_block:
                            self.error("Missing 'else' block")
                            return None

                    if else_block:
                        return ASTNode("if_statement", [condition, ASTNode("then_block", then_block.children), ASTNode("else_block", else_block.children)])
                    else:
                        return ASTNode("if_statement", [condition, ASTNode("then_block", then_block.children)])
                else:
                    self.error("Missing 'then' keyword")
                    return None
            else:
                self.error("Invalid condition in if statement")
                return None
        else:
            self.error("If statement must start with 'if' keyword")
            return None

    def parse_while_statement(self):
        #print("Parsing while statement") #Commented out for cleaner output
        if self.consume(KEYWORD, self.keywords.index("while")):
            condition = self.parse_condition()
            if condition:
                if self.consume(KEYWORD, self.keywords.index("do")):
                    loop_block = self.parse_block()
                    if not loop_block:
                        self.error("Missing 'do' block")
                        return None
                    return ASTNode("while_statement", [condition, ASTNode("loop_block", loop_block.children)])
                else:
                    self.error("Missing 'do' keyword")
                    return None
            else:
                self.error("Invalid condition in while statement")
                return None
        else:
            self.error("While statement must start with 'while' keyword")
            return None

    def parse_block(self):
        #print("Parsing block") #Commented out for cleaner output
        if self.consume(DELIMITER, self.delimiters.index("{")):
            statements = []
            while self.current_token and (self.current_token.type != DELIMITER or self.delimiters[self.current_token.attribute] != "}"):
                statement = self.parse_statement()
                if statement:
                    statements.append(statement)
                else:
                    self.advance()
                    continue
            if self.consume(DELIMITER, self.delimiters.index("}")):
                #print("Block parsed successfully") #Commented out for cleaner output
                return ASTNode("block", statements)
            else:
                self.error("Missing closing curly brace '}'")
                return None
        else:
            self.error("Block must start with an opening curly brace '{'")
            return None

    def parse_condition(self):
        #print("Parsing condition") #Commented out for cleaner output
        left_expr = self.parse_expression()
        if left_expr:
            if self.current_token and self.current_token.type == OPERATOR and self.operators[self.current_token.attribute] in [">", "<", ">=", "<=", "=="]:
                op = self.operators[self.current_token.attribute]
                self.consume(OPERATOR, self.operators.index(op))
                right_expr = self.parse_expression()
                if right_expr:
                    return ASTNode("binary_op", [left_expr, right_expr], value=op)
                else:
                    self.error("Invalid right expression in condition")
                    return None
            else:
                self.error("Missing or invalid operator in condition")
                return None
        else:
            self.error("Invalid left expression in condition")
            return None

    def parse_expression(self):
        #print("Parsing expression") #Commented out for cleaner output
        return self.parse_addition()

    def parse_addition(self):
        #print("Parsing addition") #Commented out for cleaner output
        left = self.parse_multiplication()
        while self.current_token and self.current_token.type == OPERATOR and self.operators[self.current_token.attribute] in ["+", "-"]:
            op = self.operators[self.current_token.attribute]
            self.consume(OPERATOR, self.operators.index(op))
            right = self.parse_multiplication()
            if right:
                left = ASTNode("binary_op", [left, right], value=op)
            else:
                self.error("Invalid right operand in addition/subtraction")
                return None
        return left

    def parse_multiplication(self):
        #print("Parsing multiplication") #Commented out for cleaner output
        left = self.parse_primary()
        while self.current_token and self.current_token.type == OPERATOR and self.operators[self.current_token.attribute] in ["*", "/"]:
            op = self.operators[self.current_token.attribute]
            self.consume(OPERATOR, self.operators.index(op))
            right = self.parse_primary()
            if right:
                left = ASTNode("binary_op", [left, right], value=op)
            else:
                self.error("Invalid right operand in multiplication/division")
                return None
        return left

    def parse_primary(self):
        #print("Parsing primary") #Commented out for cleaner output
        if self.current_token and self.current_token.type == NUMBER:
            number_index = self.current_token.attribute
            self.consume(NUMBER)
            return ASTNode("number", value=self.numbers[number_index])
        elif self.current_token and self.current_token.type == IDENT:
            identifier_index = self.current_token.attribute
            self.consume(IDENT)
            return ASTNode("identifier", value=self.identifiers[identifier_index])
        elif self.current_token and self.current_token.type == DELIMITER and self.delimiters[self.current_token.attribute] == "(":
            self.consume(DELIMITER, self.delimiters.index("("))
            expression = self.parse_expression()
            if expression:
                if self.consume(DELIMITER, self.delimiters.index(")")):
                    return expression
                else:
                    self.error("Missing closing parenthesis")
                    return None
            else:
                self.error("Invalid expression inside parenthesis")
                return None
        else:
            self.error("Invalid primary expression")
            return None

    def print_ast(self, node, indent=0):
        print("  " * indent + str(node))
        for child in node.children:
            self.print_ast(child, indent + 1)

# Example Usage (replace with your token stream and symbol tables)
def load_data(filename):
    data = []
    with open(filename, 'r') as f:
        for line in f:
            parts = line.strip().split(': ')
            if len(parts) == 2:
                data.append(parts[1])
    return data

def load_syntax_tables(filename):
    tables = {}
    with open(filename, 'r') as f:
        content = f.read()
        keyword_match = re.search(r"Keywords\(TokenType = 0\):\n(.*?)\n\n", content, re.DOTALL)
        operator_match = re.search(r"Operators\(TokenType = 3\):\n(.*?)\n\n", content, re.DOTALL)
        delimiter_match = re.search(r"Delimiters\(TokenType = 4\):\n(.*?)(?:\n\n|$)", content, re.DOTALL)

        tables['Keywords'] = [v for line in keyword_match.group(1).strip().split('\n') if line.strip() for k, v in [line.split(': ')]] if keyword_match else []
        tables['Operators'] = [v for line in operator_match.group(1).strip().split('\n') if line.strip() for k, v in [line.split(': ')]] if operator_match else []
        tables['Delimiters'] = [v for line in delimiter_match.group(1).strip().split('\n') if line.strip() for k, v in [line.split(': ')]] if delimiter_match else []
    return tables

# Load tokens
with open("tokens.txt", "r") as f:
    token_string = f.read().strip()
    token_list = token_string.split()
    tokens = []
    for token_str in token_list:
        match = re.match(r"<(\d+),(\d+)>", token_str)
        if match:
            token_type = int(match.group(1))
            token_attribute = int(match.group(2))
            tokens.append(Token(token_type, token_attribute))

# Load constants, identifiers, and syntax tables
numbers = load_data("../word_fenxi/constants.txt")
identifiers = load_data("../word_fenxi/identifiers.txt")
syntax_tables = load_syntax_tables("../word_fenxi/syntax_tables.txt")

keywords = syntax_tables['Keywords']
operators = syntax_tables['Operators']
delimiters = syntax_tables['Delimiters']

parser = Parser(tokens, keywords, identifiers, numbers, operators, delimiters)
ast = parser.parse()

if parser.errors:
    for error in parser.errors:
        print(error)
else:
    print("Abstract Syntax Tree:")
    parser.print_ast(ast)