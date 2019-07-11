import React, {useState,useContext} from 'react';

import * as s from "shards-react";
import * as c from '../components'

import { LoginForm } from './forms'


import api from '../appstate/api';
import utils from '../appstate/utils';
import {AppContext} from '../appstate/appcontext'


let interval;

function Login() {

  const { state, props, dispatch } = useContext(AppContext)
  const [notify, setNotify] = useState(null)
  const [msg, setMsg] = useState(null)
  const [progress, setprogress] = useState(false);
  const [progressvalue, setprogressvalue] = useState(0)

  const onSubmit = (dd) => {
    //dispatch({type:'USER_LOGGED_IN',initloading: true})
    setNotify(null)
    setMsg(null)
    setprogress(true)

    interval = setInterval(()=>{
      setprogressvalue((prev) => prev + 5)
    },500)

    api.fxns.login(dd,api.fxns.endpoint).then(rd => {
          var out = rd;
          var token=out.tkn;
          if (out.success) {
            switch (out.sd.LST) {
              case "0":
                console.log("case 0");
                break;
              case "1":
                clearInterval(interval)
                props.history.push('/Dashboard');
                var nam = out.us.nam;
                localStorage.setItem("out", JSON.stringify({ out }));
                localStorage.setItem("token", JSON.stringify({ token }));
                localStorage.setItem("nam", JSON.stringify({ nam }));
                document.cookie = "_inspire=" + token;
                dispatch({type:'USER_LOGGED_IN',payload:utils.utilfxns.getmenus(out),initloading:false})
              default:
                if (out.st && out.sm) {
                  console.log("something else came up");
                }
            }
          } else {
            clearInterval(interval)
            setNotify(true)
            setMsg(out[0].em)
            setprogress(false)
            localStorage.clear()
            document.cookie = "_metalcraft= ; expires = Thu, 01 Jan 1970 00:00:00 GMT"
            //dispatch({type:'NOTIFY',payload:out.em, login:true, title:out.et, initloading:false, ntype:'danger', time:7, place:'tc'})
          }
        },
        err => {
          dispatch({type:'NOTIFY',payload:err, login:true, title:'System error', initloading:false,ntype:'danger', time:7, place:'tc'})
        }
      );
    }
    if (progressvalue === 100) {
      clearInterval(interval)
      setprogressvalue(0)
    }
    // console.log(state);
  return (
    <React.Fragment>
    <div className="welcome d-flex justify-content-center flex-column">
  <div className="container">
    <nav className="navbar navbar-expand-lg navbar-dark pt-4 px-0">
      <a className="navbar-brand" href="/">
        <img src={require("../assets/img/shards-logo-white.svg")} className="mr-2" alt="Shards - Agency Landing Page" />
        TeckMines POS and Savings Suite
      </a>
      <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">
        <span className="navbar-toggler-icon"></span>
      </button>
      <div className="collapse navbar-collapse" id="navbarNavDropdown">
        <ul className="navbar-nav">
          <li className="nav-item active">
            <a className="nav-link" href="/">Home <span className="sr-only">(current)</span></a>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="#our-services">Our Services</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="#blog">Blog</a>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="#testimonial">Testimonials</a>
          </li>
        </ul>

        <ul className="navbar-nav ml-auto">
          <li className="nav-item">
            <a className="nav-link" href="https://twitter.com/DesignRevision"><i className="fa fa-twitter"></i></a>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="https://www.facebook.com/designrevision"><i className="fa fa-facebook"></i></a>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="https://dribbble.com/hisk"><i className="fa fa-dribbble"></i></a>
          </li>
          <li className="nav-item">
            <a className="nav-link" href="https://github.com/designrevision"><i className="fa fa-github"></i></a>
          </li>
        </ul>
      </div>
    </nav>
  </div>

  <div className="inner-wrapper mt-auto mb-auto container">
    <div className="row">
      <div className="col-md-7">
          <h1 className="welcome-heading display-4 text-white">Managing our inventory and customers</h1>
          <p className="text-white">We can help you take your idea from concept to shipping using the latest technologies and best practices available.</p>
          <a href="#our-services" className="btn btn-lg btn-outline-white btn-pill align-self-center">Learn More</a>
      </div>
      <div className="col-md-5">
        <LoginForm submit={onSubmit} progress={progress} progressvalue={progressvalue}/>
      </div>
    </div>
  </div>
  <s.Container fluid>
    <s.Row>
      <s.Col md="4">
      </s.Col>
      <s.Col md="4">
        { notify && msg && <c.Notification place='tr' theme='danger' msg={msg} time='7'/>}
      </s.Col>
      <s.Col md="4">
      </s.Col>
    </s.Row>


  </s.Container>
</div>

<div id="our-services" className="our-services section py-4">
<h3 className="section-title text-center my-5">Our Services</h3>
<div className="features py-4 mb-4">
  <div className="container">
    <div className="row">
      <div className="feature py-4 col-md-6 d-flex">
        <div className="icon text-primary mr-3"><i className="fa fa-paint-brush"></i></div>
        <div className="px-4">
            <h5>Design & Branding</h5>
            <p>Quisque mollis mi ac aliquet accumsan. Sed sed dapibus libero. Nullam luctus purus duis sensibus signiferumque.</p>
        </div>
      </div>
      <div className="feature py-4 col-md-6 d-flex">
        <div className="icon text-primary mr-3"><i className="fa fa-code"></i></div>
        <div className="px-4">
            <h5>Programming</h5>
            <p>Quisque mollis mi ac aliquet accumsan. Sed sed dapibus libero. Nullam luctus purus duis sensibus signiferumque.</p>
        </div>
      </div>
    </div>

    <div className="row">
      <div className="feature py-4 col-md-6 d-flex">
        <div className="icon text-primary mr-3"><i className="fa fa-font"></i></div>
        <div className="px-4">
            <h5>Copywriting</h5>
            <p>Quisque mollis mi ac aliquet accumsan. Sed sed dapibus libero. Nullam luctus purus duis sensibus signiferumque.</p>
        </div>
      </div>
      <div className="feature py-4 col-md-6 d-flex">
        <div className="icon text-primary mr-3"><i className="fa fa-support"></i></div>
        <div className="px-4">
            <h5>Training & Support</h5>
            <p>Quisque mollis mi ac aliquet accumsan. Sed sed dapibus libero. Nullam luctus purus duis sensibus signiferumque.</p>
        </div>
      </div>
    </div>
  </div>
</div>
</div>


<div id="blog" className="blog section section-invert py-4">
<h3 className="section-title text-center m-5">Latest Posts</h3>

<div className="container">
  <div className="py-4">
    <div className="row">
      <div className="card-deck">
      <div className="col-md-12 col-lg-4">
        <div className="card mb-4">
          <img className="card-img-top" src={require("../assets/img/card-1.jpg")} alt="Card image cap" />
          <div className="card-body">
            <h4 className="card-title">Find Great Places to Work While Travelling</h4>
            <p className="card-text">He seems sinking under the evidence could not only grieve and a visit. The father is to bless and placed in his length hid...</p>
            <a className="btn btn-primary btn-pill" href="#">Read More &rarr;</a>
          </div>
        </div>
      </div>

      <div className="col-md-12 col-lg-4">
        <div className="card mb-4">
          <img className="card-img-top" src={require("../assets/img/card-3.jpg")} alt="Card image cap" />
          <div className="card-body">
            <h4 className="card-title">Quick Tips for Improving Your Website's Design</h4>
            <p className="card-text">He seems sinking under the evidence could not only grieve and a visit. The father is to bless and placed in his length hid...</p>
            <a className="btn btn-primary btn-pill" href="#">Read More &rarr;</a>
          </div>
        </div>
      </div>

      <div className="col-md-12 col-lg-4">
        <div className="card mb-4">
          <img className="card-img-top" src={require("../assets/img/card-2.jpg")} alt="Card image cap" />
          <div className="card-body">
            <h4 className="card-title">A Designer's Tips While Travelling and Working</h4>
            <p className="card-text">He seems sinking under the evidence could not only grieve and a visit. The father is to bless and placed in his length hid...</p>
            <a className="btn btn-primary btn-pill" href="#">Read More &rarr;</a>
          </div>
        </div>
      </div>
      </div>
    </div>
  </div>
</div>
</div>

<div id="testimonial" className="testimonials section py-4">
  <h3 className="section-title text-center m-5">Testimonials</h3>
  <div className="container py-5">
    <div className="row">
        <div className="col-md-4 testimonial text-center">
            <div className="avatar rounded-circle with-shadows mb-3 ml-auto mr-auto">
                <img src={require("../assets/img/avatar-1.jpeg")}  className="w-100" alt="Testimonial Avatar" />
            </div>
            <h5 className="mb-1">Osbourne Tranter</h5>
            <span className="text-muted d-block mb-2">CEO at Megacorp</span>
            <p>Vivamus quis ex mattis, gravida erat a, iaculis urna. Proin ac eleifend tortor. Nunc in augue eget enim venenatis viverra.</p>
        </div>

        <div className="col-md-4 testimonial text-center">
            <div className="avatar rounded-circle with-shadows mb-3 ml-auto mr-auto">
                <img src={require("../assets/img/avatar-2.jpeg")} className="w-100" alt="Testimonial Avatar" />
            </div>
            <h5 className="mb-1">Darrin Ollie</h5>
            <span className="text-muted d-block mb-2">CEO at Megacorp</span>
            <p>Nullam eu ligula facilisis, commodo velit non, vulputate dolor. Aenean congue euismod vestibulum.</p>
        </div>

        <div className="col-md-4 testimonial text-center">
            <div className="avatar rounded-circle with-shadows mb-3 ml-auto mr-auto">
                <img src={require("../assets/img/avatar-3.jpeg")} className="w-100" alt="Testimonial Avatar" />
            </div>
            <h5 className="mb-1">Quinton Bruce</h5>
            <span className="text-muted d-block mb-2">CEO at Megacorp</span>
            <p> Aenean imperdiet ultrices tortor id convallis. Donec id metus magna. Morbi pretium odio faucibus blandit gravida.</p>
        </div>
    </div>
  </div>
</div>

<footer>
<nav className="navbar navbar-expand-lg navbar-dark bg-dark">
  <div className="container">
    <a className="navbar-brand" href="#">Shards Agency</a>
    <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span className="navbar-toggler-icon"></span>
    </button>
    <div className="collapse navbar-collapse" id="navbarNav">
      <ul className="navbar-nav ml-auto">
        <li className="nav-item active">
          <a className="nav-link" href="#">Home <span className="sr-only">(current)</span></a>
        </li>
        <li className="nav-item">
          <a className="nav-link" href="#">Our Services</a>
        </li>
        <li className="nav-item">
          <a className="nav-link" href="#">Blog</a>
        </li>
        <li className="nav-item">
          <a className="nav-link" href="#">Testimonials</a>
        </li>
        <li className="nav-item">
          <a className="nav-link" href="#">Contact Us</a>
        </li>
      </ul>
    </div>

  </div>
</nav>
</footer>
    </React.Fragment>
  );

}

export default Login;
