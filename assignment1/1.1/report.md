# Report

The calculator service is written in Java using JAX-WS (https://jax-ws.java.net). There are 4 classes that we use, CalculatorClient, CalculatorImpl, CalculatorInterface and CalculatorPublisher.

CalculatorInterface describes the interface that the webservice must comply to. It describes the methods that can be used by the client, namely: add(a, b), sub(a, b), mul(a, b) and div(a, b).

CalculatorPublisher publishes the service to an endpoint at http://localhost:9999/calc using the interface as described above.

CalculatorImpl is the actual implementation of the methods described in the interface, we are doing basic calculations, so the implementation of these methods is straightforward.

CalculatorClient is a simple client that we created to validate that the publisher and implementation were working correctly.

All 4 classes are minimal in size because JAX-WS offers all the bootstrapping required to run the service.
