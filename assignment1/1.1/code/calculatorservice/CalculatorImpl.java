package calculatorservice;

import javax.jws.WebService;

//Service Implementation
@WebService(endpointInterface = "calculatorservice.CalculatorInterface")
public class CalculatorImpl implements CalculatorInterface {
    @Override
    public double add(double a, double b) {
        return a + b;
    }
    @Override
    public double sub(double a, double b) {
        return a - b;
    }
    @Override
    public double mul(double a, double b) {
        return a * b;
    }
    @Override
    public double div(double a, double b) {
        return a / b;
    }
}