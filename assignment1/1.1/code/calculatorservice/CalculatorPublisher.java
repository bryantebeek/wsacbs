package calculatorservice;

import javax.xml.ws.Endpoint;

//Endpoint publisher
public class CalculatorPublisher {

    public static void main(String[] args) {
        Endpoint.publish("http://localhost:9999/calc", new CalculatorImpl());
    }

}