import {useEffect,useState} from 'react';
import api from './api';

export default {
  utilfxns: {
    getmenus: params => getmenus(params),
    getPDF: (params,filename,fmt) => getPDF(params,filename,fmt),
    apipdf: (params,filename,fmt) => apipdf(params,filename,fmt),
    combo:(type,nam) => combo(type,nam),
    getcookie: (cookie) => getcookie(cookie),
    fetchdata: (searchterm,svc,pos,plm) => fetchdata(searchterm,svc,pos,plm),
    fetchfile: (searchterm,svc,fmt) => fetchfile(searchterm,svc,fmt),
    test: (searchterm,svc,pos,plm) => test(searchterm,svc,pos,plm),
    submitdata: (fm) => submitdata(fm),
    sales: (fm) => sales(fm),
    getuid: () => getuid(),
    validate: (fm) => validate(fm),
    applicationstart:(dispatch) => applicationstart(dispatch),
    refetchdata: (searchterm,svc,pos,plm) => refetchdata(searchterm,svc,pos,plm),
    ag:() => ag()
  }
}

function getmenus(params) {
  const mn = params.mn;
  const upv = params.pv
  var mmi,mbar=[];
  for(mmi in mn){
    var mmn = mn[mmi].nam;
    var sm = mn[mmi].smn;
          //var bt = this.upv[mmi].btx;
    var smenu = [];
    var oksmn = [];
    for(var smn in sm){
        var smf = sm[smn];
        var mni = {text:smn};
        var c = mkbuts(smf,upv); //added
        //smenu.push({text:smn,cid:smf}); removed
        smenu.push({text:smn,cid:smf,ssm:c}); //added
    }
    oksmn.push(Object.keys(smenu));
    mbar.push({text:mmn,smenus:smenu,objk:oksmn,icon:mmi});
  }
  return mbar;
}

function mkbuts(file,upv){
  var i,j=0,pv=upv,bb=[],obt=[];
  for(i in pv){
    if(pv[i].acf==file){
      var nb = pv[i].btx;
      var mb = pv[i].bfn;
      bb.push({text:nb,fn:mb});
    }
  }
  return bb;
}

function getPDF(params,filename,fmt) {
  var data = fmt === 'pdf' ? new Blob([params], {type: 'application/pdf'}) : new Blob([params], {type: 'text/csv'});
  var pdfURL = window.URL.createObjectURL(data);
  var tempLink = document.createElement('a');
  var d = new Date();

  var curr_date = d.getDate();
  var curr_month = d.getMonth();
  var curr_year = d.getFullYear();
  var curr_hour = d.getHours();
  var curr_min = d.getMinutes();
  var curr_sec = d.getSeconds();

  tempLink.href = pdfURL;
  tempLink.setAttribute('download', filename + "_" +curr_date + "-" + curr_month + "-" + curr_year+"_"+curr_hour+"_"+curr_min+"_"+curr_sec+'.'+fmt);
  tempLink.click();
}

const apipdf = (params,filename,fmt) =>{
  var newBlob = new Blob([params], {type: "application/pdf"});
  if (window.navigator && window.navigator.msSaveOrOpenBlob) {
    window.navigator.msSaveOrOpenBlob(newBlob);
    return;
  }

  const data = window.URL.createObjectURL(newBlob);
  var link = document.createElement('a');
  link.href = data;
  link.download=filename.split(';')[1].split('=')[1].replace(/"/g,'');
  window.open(link)
  // link.click();
  //document.body.removeChild(link);

  setTimeout(function(){
    // window.print(link)
    // For Firefox it is necessary to delay revoking the ObjectURL
    window.URL.revokeObjectURL(data);
  }, 2000);
}

const combo = (type,nam) => {
  const [val, setvalue] = useState(null)

  // useEffect(() => {
    var fm = new FormData(),cbo=[];
    fm.append('s', 'cb');fm.append('a', 'combo');fm.append('df',type);
    fm.append("ssi", getcookie('_metalcraft'));fm.append("uid", getuid());
    fm.append('m','l');

    // api.fxns.combo(fm,api.fxns.endpoint).then(rd => {
    //   rd.sd.map(opt => {
    //     cbo.push({label:opt.nam,value:opt.rid,nam:nam});
    //   })
    //   setvalue(cbo)
    // });

  // },[])

  // return () => {
  //   console.log('bye');
  // };
  return api.fxns.combo(fm,api.fxns.endpoint);
}

const applicationstart = (dispatch) => {
  let isMounted;
  const [value, setValue] = useState(null)
  const [msg, setMsg] = useState(null)

  useEffect(() => {
    isMounted = true;
    var fm = new FormData();
    fm.append('s', '');fm.append('m', document.cookie.split("=")[1]);
    dispatch({type:'LOADING', initloading: true})

    if (document.cookie.split("=")[1] === undefined) {
      api.fxns.base(fm,api.fxns.endpoint).then(dd => {
        if(isMounted){
          console.log(dd);
          document.cookie = "_metalcraft=" + dd["PHPSESSID"];
          setValue(dd["PHPSESSID"])
          dispatch({type:'LOADING', initloading: false})
        }
      }, err=>{

        setValue(false)
        setMsg(err.toString()+' Application Start')
        dispatch({type:'LOADING', initloading: false})
      });
    }else {
      setValue(true)
      dispatch({type:'LOADING', initloading: false})
    }

      return () => {
        isMounted = false
      };
  },[])

  return {value,msg};
}

const refetchdata = (searchterm,service,pos,plm) => {
  let isMounted;
  // const [value, setvalue] = useState(null)
  // const [msg, setmsg] = useState(null)

  // useEffect(() => {
  //   isMounted = true;

    fetchdata(searchterm,service,pos,plm).then(dd => dd)


  //   return () => {
  //     isMounted = false
  //   };
  // },[])

  // return {value,msg};
}

const fetchdata = (searchterm,svc,pos,plm) => {
  var fm = new FormData(),props,name;
  if (svc === 'products') {
    props = '{"rid":"n","nam":"t","sno":"t","sdt":"t","edt":"t","shi":"n","sts":"n","pos":"n","plm":"n"}'
    var rid = searchterm ? searchterm : ''
    fm.append('shi',rid);
  }  else if(svc === 'categories') {
    props = '{"rid":"n","nam":"t","shc":"t","sts":"n","pos":"n","plm":"n"}'
    fm.append('nam',searchterm)
  } else if(svc === 'shops') {
    props = '{"rid":"n","nam":"t","shc":"t","sts":"n","pos":"n","plm":"n"}'
    fm.append('nam',searchterm)
  } else if (svc === 'member') {
    props = '{"rid":"n","nam":"t","cod":"t","sdt":"t","edt":"t","sts":"n","pos":"n","plm":"n"}'
    fm.append('nam',searchterm)
  } else if (svc === 'savings') {
    props = '{"cid":"n"}'
    fm.append('cid',searchterm)
  }
  fm.append('s', 'fd');fm.append('a', 'find');fm.append('df','sp_'+svc+'_find');
  fm.append("ssi", getcookie('_metalcraft'));fm.append("uid", getuid());
  fm.append('m','l');fm.append('dd',props);fm.append('plm',plm);fm.append('pos',pos);

  return api.fxns.datasubmit(fm,api.fxns.endpoint);
}

const fetchfile = (searchterm,svc,fmt) => {
  var fm = new FormData(),props,name;
  if (svc === 'region') {
    props = '{"rid":"n","nam":"t","shc":"t","sts":"n","pos":"n","plm":"n"}'
    fm.append('nam',searchterm)
  }  else if(svc === 'location') {
    props = '{"rid":"n","nam":"t","shc":"t","rnm":"t","rsc":"t","rgi":"n","osc":"t","cid":"n","sts":"n","pos":"n","plm":"n"}'
    fm.append('rgi',searchterm)
  } else if(svc === 'products'){
    props = '{"rid":"n","nam":"t","sno":"t","sdt":"t","edt":"t","shi":"n","sts":"n","pos":"n","plm":"n"}'
    var rid = searchterm ? searchterm : ''
    fm.append('shi',rid);
  }
  fm.append('s', 'rp');fm.append('a', 'receipt');fm.append('df','sp_'+svc+'_find');
  fm.append("ssi", getcookie('_metalcraft'));fm.append("uid", getuid());
  fm.append('m','l');fm.append('dd',props);fm.append('plm','');fm.append('pos','');

  return api.fxns.getfile(fm,api.fxns.endpoint);
}

const test = async (searchterm,svc,pos,plm) => {
  var fm = new FormData(),props,name;
  if (svc === 'products') {
    props = '{"rid":"n","nam":"t","sno":"t","sdt":"t","edt":"t","shi":"n","sts":"n","pos":"n","plm":"n"}'
    var rid = searchterm ? searchterm : ''
    fm.append('shi',rid);
  }
  fm.append('s', 'fd');fm.append('a', 'find');fm.append('df','sp_'+svc+'_find');
  fm.append("ssi", getcookie('_metalcraft'));fm.append("uid", getuid());
  fm.append('m','l');fm.append('dd',props);fm.append('plm',plm);fm.append('pos',pos);

  var response = await fetch(api.fxns.endpoint,{method: 'post', body: fm})
  let data = await response.json();
  const b = ag(data);
  // console.log(b);
  return b;
}

function ag(data){
  // console.log(data);
  // const df = test('','products',0,10)
  // df.then(dd=>console.log(dd))
  return data;
}


const submitdata = (dd) => {
  const {val,sdt,form,dbf,s,a, cid} = dd;
  var fm = new FormData(),props={};
  // for (var key in val) {
  //   if(key === 'sdtt'){
  //     var dt = val.sdtt.toISOString();
  //     fm.append(key,dt);
  //   }else {
  //     fm.append(key,val[key]);
  //   }
  //   props[key]= key.substr(key.length-1);
  // }
  if(typeof form != 'string'){
    for (var i = 0; i < form.length-1; i++) {
      if(form[i]['props']['name'] === 'sdtt'){
        var dt = val.sdtt.toISOString();
        fm.append(form[i]['props']['name'],dt);
      } else {
        fm.append(form[i]['props']['name'],form[i]['props']['value']);
      }
      props[form[i]['props']['name']]= form[i]['props']['name'].substr(form[i]['props']['name'].length-1);
    }
  } else {
      fm.append('amt',val);fm.append('cid',cid);
      props['cid']='n';props['amt']= 'n';
  }

  fm.append('ssi',getcookie('_metalcraft'));fm.append("uid", getuid());
  fm.append("s", s);fm.append("a", a);fm.append('df',dbf);
  fm.append('m','l');fm.append('dd',JSON.stringify(props))

  return api.fxns.datasubmit(fm,api.fxns.endpoint);
}

const sales = (dd) => {
  const {items,f,s,a,fp,val} = dd;

  var fm = new FormData();

  fm.append('ssi',getcookie('_metalcraft'));fm.append("uid", getuid());
  fm.append("s", s);fm.append("a", a);fm.append('df',f);fm.append('fp',fp)
  fm.append('m','l');fm.append('itm',JSON.stringify(items));fm.append('val',JSON.stringify(val));

  return api.fxns.getfile(fm,api.fxns.endpoint);
}

const validate = (form) => {

  var msg,rad=[];
  // for (var key in form) {
  //   if(!form[key]['props']['value']){
  //       msg = form[key]['props']['id'] + ' is Required';
  //       break;
  //   }
  // }
  for (var i = 0; i < form.length-1; i++) {
    if (form[i]['props']['id'] == 'radio') {
      rad.push(form[i]['props']['checked'])
    }
    if(!form[i]['props']['value'] && form[i]['props']['id'] != 'radio'){
        msg = form[i]['props']['id'] + ' is Required';
        break;
    }
  }
  if (rad.includes(true)) {

  }

  return msg;
}

const getcookie = (name) => {
  var value = "; " + document.cookie;
  var parts = value.split("; " + name + "=");
  if (parts.length == 2) return parts.pop().split(";").shift();
}
const getuid = () => {
  var out = JSON.parse(localStorage.getItem('out'));
  return out.out.us.rid;
}
