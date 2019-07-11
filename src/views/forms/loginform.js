import React, { useState} from 'react'

import * as s from '../../shardslib';
import * as c from '../../components';

import utils from '../../appstate/utils';


function LoginForm({submit, progress, progressvalue}) {

  const [val, setValue]=useState({unm:'',pwd:''});


  const handleSubmit = (e) => {
    if(!val.unm || !val.pwd) return;
    var fm = new FormData()

    var cookie = utils.utilfxns.getcookie('_metalcraft');
    fm.append('unm',val.unm);fm.append('pwd',val.pwd);fm.append("s", "auth");
    fm.append("a", "authverify");fm.append("ssi", cookie);
    fm.append("ctx", "2");fm.append('m','l');

    submit(fm)
    //setValue({unm:'',pwd:''})
  }

  const onChange = e => setValue({...val, [e.target.name]: e.target.value})

  return(
    <React.Fragment>
    <div className="content">

          <s.Card small className="login">
            <s.CardHeader className="border-bottom">
            { progress && <c.ProgressBar theme="danger" value={progressvalue}/>}
              <h6 className="m-0">Login</h6>
            </s.CardHeader>
            <s.ListGroup flush>
              <s.ListGroupItem className="p-3">
                <c.InputField id="feUsername" label="Username" placeholder="Username" type='text' name='unm' value={val.unm} onChange={onChange}/>
                <c.InputField id="fePassword" label="Password" placeholder="Password" type='password' name='pwd' value={val.pwd} onChange={onChange}/>
              </s.ListGroupItem>

              <s.ListGroupItem>
                <s.Button id="btn" type="submit" onClick={handleSubmit}>Submit</s.Button>
              </s.ListGroupItem>
            </s.ListGroup>
          </s.Card>
    </div>
    </React.Fragment>
  );
}


export default LoginForm;
