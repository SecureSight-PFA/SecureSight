import http from 'k6/http';
import { sleep, check } from 'k6';

const BASE_URL = 'http://k8s-sockshop-sockshop-152ce06d68-1928472948.us-east-2.elb.amazonaws.com/';

export const options = {
  stages: [
    { duration: '1m', target: 50 },
    { duration: '2m', target: 150 },
    { duration: '2m', target: 300 },
    { duration: '1m', target: 0 },
  ],
};

export default function () {

  // user lands on frontend
  let home = http.get(`${BASE_URL}/`);
  check(home, { 'home ok': r => r.status === 200 });

  sleep(0.5);

  // browse catalogue (catalogue service)
  let cat = http.get(`${BASE_URL}/catalogue`);
  check(cat, { 'catalogue ok': r => r.status === 200 });

  sleep(0.5);

  // cart (carts service)
  let cart = http.get(`${BASE_URL}/cart`);
  check(cart, { 'cart ok': r => r.status === 200 });

  sleep(0.5);

  // user service
  let user = http.get(`${BASE_URL}/user`);
  check(user, { 'user ok': r => r.status === 200 });

  sleep(0.5);

  // orders OR shipping OR payment (randomized load distribution)
  let extra = [
    '/orders',
    '/shipping',
    '/payment'
  ];

  let path = extra[Math.floor(Math.random() * extra.length)];

  let res = http.get(`${BASE_URL}${path}`);
  check(res, { 'extra service ok': r => r.status === 200 });

  sleep(0.5);
}