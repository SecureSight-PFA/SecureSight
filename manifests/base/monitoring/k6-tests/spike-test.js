import http from 'k6/http';
import { sleep, check } from 'k6';

const BASE_URL = 'http://k8s-sockshop-sockshop-152ce06d68-1928472948.us-east-2.elb.amazonaws.com/';

export const options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '10s', target: 500 },  
    { duration: '1m', target: 500 },
    { duration: '30s', target: 20 },
    { duration: '30s', target: 0 },
  ],
};

export default function () {

  // simulate real user session flow
  let res1 = http.get(`${BASE_URL}/`);
  check(res1, { 'home 200': r => r.status === 200 });

  sleep(0.2);

  let endpoints = [
    '/catalogue',
    '/cart',
    '/orders',
    '/user',
    '/shipping',
    '/payment'
  ];

  let path = endpoints[Math.floor(Math.random() * endpoints.length)];

  let res2 = http.get(`${BASE_URL}${path}`);

  check(res2, {
    'service OK': (r) => r.status === 200,
  });

  sleep(0.2);
}