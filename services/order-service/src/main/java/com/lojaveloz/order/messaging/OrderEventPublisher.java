package com.lojaveloz.order.messaging;

import com.lojaveloz.order.model.Order;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class OrderEventPublisher {

    private final RabbitTemplate rabbitTemplate;

    @Value("${rabbitmq.exchanges.orders}")
    private String ordersExchange;

    @Value("${rabbitmq.routing-keys.orderCreated}")
    private String orderCreatedKey;

    public void publishOrderCreated(Order order) {
        OrderCreatedEvent event = OrderCreatedEvent.builder()
            .orderId(order.getId().toString())
            .customerId(order.getCustomerId())
            .totalAmount(order.getTotalAmount())
            .items(order.getItems())
            .build();

        rabbitTemplate.convertAndSend(ordersExchange, orderCreatedKey, event);
        log.info("Event published exchange={} routingKey={} orderId={}", ordersExchange, orderCreatedKey, order.getId());
    }
}
