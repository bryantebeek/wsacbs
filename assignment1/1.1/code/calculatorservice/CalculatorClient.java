package calculatorservice;

import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;

public class CalculatorClient{

    public static void main(String[] args) throws Exception {

        URL url = new URL("http://localhost:9999/calc?wsdl");

        //1st argument service URI, refer to wsdl document above
        //2nd argument is service name, refer to wsdl document above
        QName qname = new QName("http://calculatorservice/", "CalculatorImplService");

        Service service = Service.create(url, qname);

        CalculatorInterface hello = service.getPort(CalculatorInterface.class);

        System.out.println(hello.add(10, 80.55));
        System.out.println(hello.sub(10, 80.55));
        System.out.println(hello.div(10, 80.55));

    }

}