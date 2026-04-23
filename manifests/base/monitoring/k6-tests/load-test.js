import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = 'http://k8s-sockshop-sockshop-152ce06d68-1928472948.us-east-2.elb.amazonaws.com/';

export const options = {
  vus: 30,
  duration: '3m',
};

export default function () {

  // 1. User enters frontend
  let home = http.get(`${BASE_URL}/`);
  check(home, { 'frontend OK': r => r.status === 200 });

  sleep(1);

  // 2. User browses catalogue (catalogue service involved)
  let catalogue = http.get(`${BASE_URL}/catalogue`);
  check(catalogue, { 'catalogue OK': r => r.status === 200 });

  sleep(1);

  // 3. User views cart (carts service involved)
  let cart = http.get(`${BASE_URL}/cart`);
  check(cart, { 'cart OK': r => r.status === 200 });

  sleep(1);

  // 4. User profile / login (user service involved)
  let user = http.get(`${BASE_URL}/user`);
  check(user, { 'user OK': r => r.status === 200 });

  sleep(1);

  // 5. Orders page (orders service involved)
  let orders = http.get(`${BASE_URL}/orders`);
  check(orders, { 'orders OK': r => r.status === 200 });

  sleep(1);

  // 6. Shipping page (shipping service involved)
  let shipping = http.get(`${BASE_URL}/shipping`);
  check(shipping, { 'shipping OK': r => r.status === 200 });

  sleep(1);

  // 7. Payment page (payment service involved)
  let payment = http.get(`${BASE_URL}/payment`);
  check(payment, { 'payment OK': r => r.status === 200 });

  sleep(2);
}