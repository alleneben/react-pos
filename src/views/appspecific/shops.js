
import React, {useContext, useState,useEffect, useReducer} from 'react';

import api from '../../appstate/api';
import utils from '../../appstate/utils';
import { AppContext } from '../../appstate/appcontext';

import * as s from '../../shardslib';
import * as c from '../../components';




function Shops(props) {
  const [cstate, setState] = useReducer(
    (cstate, newState) => ({...cstate, ...newState}),{
      loading: false, data: [], pos: 0, plm: 10}
    )
  const { state, dispatch } = useContext(AppContext)


  useEffect(() => {
    setState({loading: true})
    utils.utilfxns.fetchdata('','shops',cstate.pos,cstate.plm).then(rd => {
      var out = rd;
      if(out.success){
        setState({loading:false, data: rd.sd})
      } else {
        setState({loading: false})
      }
    },err => {
      console.log(err);
    })

    return () => {
      console.log('bye');
    };
  },[])

  const route = (searchterm,svc,id) => {
    dispatch({type:'ID',payload:id})
    //props.history.push('/home/Regions/'+svc)
  }

  const makecontent = () => {
    var link = '/shops/';
    if(cstate.loading ) return <>fetching data.... <c.Notification theme='danger' msg='Slow Connection' time='7'/></>
    var shops = cstate.data.map((shop,key) => {

      return <s.Col md='3' className='animated rollIn regioncard' key={key}><c.ShopCard name={shop.nam} rct={shop.rct} link={link+shop.rid+'/products'}/></s.Col>
    })
    return <s.Row >{shops}</s.Row>;
  }
  const makesubmenus = () => {
    //console.log(state);
    if (!!!state.auhmn.text) return;
    return ''
  }

  const createfn = () => {
    console.log('create');
  }

  const maketabletest = () =>{
    const tbcfg = {header:["S/No","Item","Retail Price 1","Retail Price 2","Whole Sale Price","Qty","Qty/group","Bulk"],flds:[{n:'nam',f:'t'},{n:'prc',f:'d'},{n:'rsb',f:'d'},{n:'wrsb',f:'d'},{n:'qty',f:'n'},{n:'qpb',f:'n'},{n:'blk',f:'n'}]}
    const p = '{"rid":"n","nam":"t","sno":"t","sdt":"t","edt":"t","shi":"n","sts":"n","pos":"n","plm":"n"}'
    return <c.MagsterDataTable phld='Items' btns={[]} tbcfg={tbcfg} svc='fd' a='find' p={p} dbf='products'/>
  }


  return (
    <s.Container fluid className="main-content-container px-4 pb-4 pt-4">
      <s.Row>
      <div className="menu-container">{ makesubmenus() }</div>
        <s.Col lg="12" md="12">
          { cstate.loading ? <><s.Spinner size={50} spinnerColor={"#333"} spinnerWidth={2} visible={cstate.loading} /></> : makecontent()  }
          { /*maketabletest()*/}
        </s.Col>
      </s.Row>
    </s.Container>
  );
}


export default Shops;
