import axios from "axios";

import endpoint from '../endpoint.config';

const httpService = axios.create({
    baseURL: endpoint.BaseUrl,
    headers: {
        "Content-type": "application/json"
    }
});

// request interceptor
httpService.interceptors.request.use(config => {
    // ...
    return config
}, err => {
    return Promise.reject(err)
})

// response interceptor
httpService.interceptors.response.use(response => {
    // ...
    return response
}, err => {
    return Promise.reject(err)
})

export default httpService
