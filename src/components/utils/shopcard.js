import React from 'react';
import { Link } from 'react-router-dom';

import * as s from '../../shardslib'





const ShopCard = ({ name,link,rct }) => {

  return (
    <Link to={`${link}`}>
      {/*<div className="card-product">
        <div className="card-product-infos">
          <h2>{ name }</h2>
          <p>All assets in  <strong>{ name }</strong></p>
        </div>
      </div>*/}
      <s.Card small className="card-post mb-4">
        <s.CardBody>
          <h5 className="card-title">{ name }</h5>
          <p className="card-text text-muted"> All products in { name }</p>
        </s.CardBody>
        <s.CardFooter className="border-top d-flex">
          <div className="card-post__author d-flex">
            <div className="d-flex flex-column justify-content-center ml-3">
              <span className="card-post__author-name">

              </span>
              <small className="text-muted">{rct} items(s)</small>
            </div>
          </div>
          <div className="my-auto ml-auto">
            <s.Button size="sm" theme="white">
              <i className="far fa-bookmark mr-1" /> View
            </s.Button>
          </div>
        </s.CardFooter>
      </s.Card>
    </Link>
  )
}

export default ShopCard;
