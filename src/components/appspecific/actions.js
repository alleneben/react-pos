import React, { useState } from "react";
import PropTypes from "prop-types";

import * as s from '../../shardslib'

const Actions = ({ title, clsnm, placeholder, submit,data,cid }) => {
    const [val, setval] = useState({cidn:cid});

    const onchange = (e) => {
      setval({...val,[e.target.name]:e.target.value})
    }

    const handlesubmit = (dbf,s,a) => {
      if(val.amtn == undefined) return 'Field is empty';
      submit({val:val,sdt:'',form:'',dbf:dbf,s:s,a:a});
      setval({})
    }
    const makeitems = () => {
      return  <>
          <s.ListGroupItem className="d-flex px-3 border-0">
              <s.InputGroup seamless className="mb-3">
                {<s.FormInput placeholder={placeholder} name="amtn" type="number" value={val.amtn || ''} onChange={onchange}/>}
            </s.InputGroup>
          </s.ListGroupItem>
          <s.ListGroupItem className="d-flex px-3 border-0">
            <s.Button outline theme="accent" size="sm" onClick={() => handlesubmit('sp_savings_add','ad','deposit')}>
              <i className="material-icons">save</i> Save
            </s.Button>
          </s.ListGroupItem>
        </>
    }
    return (
      <s.Card small className={ clsnm }>
        <s.CardHeader className="border-bottom">
          <h6 className="m-0">{title}</h6>
        </s.CardHeader>

        <s.CardBody className="p-0">
          <s.ListGroup flush>
          { makeitems() }
          </s.ListGroup>
        </s.CardBody>
      </s.Card>
    );
}


Actions.propTypes = {
  /**
   * The component's title.
   */
  title: PropTypes.string
};

Actions.defaultProps = {
  title: "Deposit"
};

export default Actions;
