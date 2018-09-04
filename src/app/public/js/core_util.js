
function execCopy(string){
  var temp = document.createElement('div');

  temp.appendChild(document.createElement('pre')).textContent = string;

  var s = temp.style;
  s.position = 'fixed';
  s.left = '-100%';

  document.body.appendChild(temp);
  document.getSelection().selectAllChildren(temp);

  var result = document.execCommand('copy');

  document.body.removeChild(temp);
  return result;
}

String.prototype.isEmpty = function() {
  return (this === "") || (this === undefined) || (this == null);
}

function inherits(ctor, superCtor) {
  if (ctor === undefined || ctor === null)
    throw new TypeError('The constructor to `inherits` must not be ' +
                        'null or undefined.');

  if (superCtor === undefined || superCtor === null)
    throw new TypeError('The super constructor to `inherits` must not ' +
                        'be null or undefined.');

  if (superCtor.prototype === undefined)
    throw new TypeError('The super constructor to `inherits` must ' +
                        'have a prototype.');

  ctor.super_ = superCtor;
  Object.setPrototypeOf(ctor.prototype, superCtor.prototype);
//  ctor.prototype = Object.create(superCtor.prototype, {
//    constructor: {
//      value: ctor,
//      enumerable: false,
//      writable: true,
//      configurable: true
//    }
//  });
}


