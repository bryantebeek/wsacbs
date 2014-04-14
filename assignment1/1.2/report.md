# Report

We used the Flask microframework for Python to implement the calculator service.
When we hit the route GET /calc/<equation> we are going to substitute spaces in the equation with a +, this is because a + in a url encodes to a space, but we want the original + instead for the calculation.
Next we use a stack to calculate the outcome of the reverse polish notation over the given equation (it has to be in rpn format).
We catch the errors for division by zero and any other error as a syntax error and return the required message + status code for the error.
