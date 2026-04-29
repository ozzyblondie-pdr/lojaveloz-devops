package com.lojaveloz.order.service;

import com.lojaveloz.order.messaging.OrderEventPublisher;
import com.lojaveloz.order.model.Order;
import com.lojaveloz.order.model.OrderStatus;
import com.lojaveloz.order.repository.OrderRepository;
import io.micrometer.core.instrument.MeterRegistry;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderEventPublisher eventPublisher;
    private final MeterRegistry meterRegistry;

    @Transactional
    public Order createOrder(Order order) {
        BigDecimal total = order.getItems().stream()
            .map(item -> item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        order.setTotalAmount(total);

        Order saved = orderRepository.save(order);
        log.info("Order created orderId={} customerId={} total={}", saved.getId(), saved.getCustomerId(), total);

        eventPublisher.publishOrderCreated(saved);
        meterRegistry.counter("orders.created").increment();

        return saved;
    }

    @Transactional(readOnly = true)
    public Order findById(UUID id) {
        return orderRepository.findById(id)
            .orElseThrow(() -> new OrderNotFoundException(id));
    }

    @Transactional(readOnly = true)
    public List<Order> findByCustomer(String customerId) {
        return orderRepository.findByCustomerId(customerId);
    }

    @Transactional
    public Order cancelOrder(UUID id) {
        Order order = findById(id);
        if (order.getStatus() == OrderStatus.CONFIRMED || order.getStatus() == OrderStatus.SHIPPED) {
            throw new IllegalStateException("Cannot cancel order in status: " + order.getStatus());
        }
        order.setStatus(OrderStatus.CANCELLED);
        log.info("Order cancelled orderId={}", id);
        meterRegistry.counter("orders.cancelled").increment();
        return orderRepository.save(order);
    }
}
