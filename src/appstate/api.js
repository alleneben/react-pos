
export default {
  fxns: {
    // endpoint:'http://172.104.244.238/biz/bis/',
    // endpoint:'http://172.105.69.234/biz/bis/',
    endpoint:'http://pos.loc/biz/bis/',
    //endpoint:'http://metalcraftapp.com/biz/bis/',
    //imageurl:'http://metalcraftapp.com/biz/files/photos/',
    login: (params,url) => fetch(url,{method: 'post', body: params}).then(res => res.json()),
    base: (params,url) => fetch(url,{method: 'post', body: params}).then(res => res.json()),
    basicdata: (params,url) => fetch(url,{method: 'post', body: params}).then(res => res.json()),
    loaddata: (params,url) => fetch(url,{method: 'post', body: params}).then(res => res.json()),
    send: (params,url) => fetch(url,{method: 'post', body: params}).then(res => res.json()),
    getfile: (params,url) => fetch(url,{method: 'post', body: params})
                             .then(res => [res.blob(), res.headers.get('content-disposition')]),
    logout: (params,url) => fetch(url,{method: 'post', body: params}).then(res => res.json()),
    usercombo: (params,url) => fetch(url,{method: 'post', body: params}).then(res => res.json()),
    combo: (params,url) => fetch(url,{method: 'post', body: params}).then(res => res.json()),
    datasubmit: (params,url) => fetch(url, {method: 'post', body: params}).then(res => res.json()),
  }
}
