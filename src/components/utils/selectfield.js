import React from 'react'

import * as s from '../../shardslib';

let select;
function SelectField({align,md,label,id,placeholder,type,name,value,onChange,readOnly,options}) {
  if(value){
    let val = options[value].value;
    select = <s.Select readOnly={readOnly} id={id}  name={name} onChange={onChange} options={options} defaultValue={options[val]} />
  } else {
    select = <s.Select readOnly={readOnly} id={id}  name={name} onChange={onChange} options={options} />
  }


  return(
    <React.Fragment>
      <s.Col className={align} md={md}>
        <s.FormGroup>
          <label htmlFor={id}>{label}</label>
          { select }
        </s.FormGroup>
      </s.Col>
    </React.Fragment>

  );
}


export default SelectField;
