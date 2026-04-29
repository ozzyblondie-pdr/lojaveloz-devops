package com.lojaveloz.order.model;

public enum OrderStatus {
    PENDING,
    PAYMENT_PROCESSING,
    PAYMENT_APPROVED,
    PAYMENT_REJECTED,
    STOCK_RESERVED,
    CONFIRMED,
    SHIPPED,
    DELIVERED,
    CANCELLED
}
