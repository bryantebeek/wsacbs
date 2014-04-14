from flask import Flask, abort
import string, operator

ARITHMETIC_OPERATORS = {
    '+':  operator.add, '-':  operator.sub,
    '*':  operator.mul, '/':  operator.div
}

def rpn(expression, operators=ARITHMETIC_OPERATORS):
    stack = []
    for val in expression.split(' '):
        if val in operators:
            f = operators[val]
            stack[-2:] = [f(*stack[-2:])]
        else:
            stack.append(float(val))

    if len(stack) > 1:
        raise InvalidSyntaxError;

    return stack.pop()


app = Flask(__name__)

@app.route("/calc/<equation>")
def calc(equation):
    try:
        equation = equation.replace(' ', '+').replace('&', ' ').replace(':', '/')

        return str(rpn(equation))
    except ZeroDivisionError:
        return "division by zero", 400
    except:
        return "syntax error", 400

if __name__ == "__main__":
    app.run(debug=True)
