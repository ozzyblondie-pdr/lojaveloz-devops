package com.lojaveloz.order.messaging;

import com.lojaveloz.order.model.OrderItem;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Data
@Builder
public class OrderCreatedEvent {
    private String orderId;
    private String customerId;
    private BigDecimal totalAmount;
    private List<OrderItem> items;

    @Builder.Default
    private Instant occurredAt = Instant.now();

    @Builder.Default
    private String eventId = UUID.randomUUID().toString();
}
