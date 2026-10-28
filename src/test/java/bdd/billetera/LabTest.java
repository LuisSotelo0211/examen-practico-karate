package bdd.billetera;

import com.intuit.karate.junit5.Karate;

class LabTest {

    @Karate.Test
    Karate ejecutarRegresion() {
        return Karate.run("regresion").relativeTo(getClass());
    }
}