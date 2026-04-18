package com.example.testapp;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class SampleTest {

    @BeforeEach
    public void setUp() {
        // Test setup
    }

    @Test
    public void testExample() {
        assertTrue(true, "This test should pass");
    }

    @Test
    public void testArithmetic() {
        assertEquals(2, 1 + 1, "1 + 1 should equal 2");
    }
}
