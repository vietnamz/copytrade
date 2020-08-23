import http from "../utils/http-common";
import {AxiosPromise, AxiosResponse} from 'axios';

class PrimeDataService {
    get(num: string) : AxiosPromise {
        return http.get<AxiosResponse>(`/prime?number=${num}`);
    }
}

export default new PrimeDataService();
