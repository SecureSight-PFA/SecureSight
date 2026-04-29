import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = 'http://k8s-sockshop-sockshop-152ce06d68-1928472948.us-east-2.elb.amazonaws.com/';

export const options = {
  vus: 30,
  duration: '2m',
};

export default function () {

  // 1. User enters frontend
  let home = http.get(`${BASE_URL}/`);
  check(home, { 'frontend OK': r => r.status === 200 });

  sleep(1);

  // 2. User browses catalogue (catalogue service involved)
  let catalogue = http.get(`${BASE_URL}/category.html`);
  check(catalogue, { 'catalogue OK': r => r.status === 200 });

  sleep(1);

  // 3. User views cart (carts service involved)
  let cart = http.get(`${BASE_URL}/basket.html`);
  check(cart, { 'cart OK': r => r.status === 200 });

  sleep(1);

  // 4. Orders page (orders service involved)
  let orders = http.get(`${BASE_URL}/customer-orders.html`);
  check(orders, { 'orders OK': r => r.status === 200 });

  sleep(2);
}