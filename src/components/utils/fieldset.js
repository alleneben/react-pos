import React from 'react'






const FieldSet = ({ children, label }) => {



  return (
    <div className="row">
      <label>{ label }</label>
      { children }
    </div>
  );
}

export default FieldSet;
