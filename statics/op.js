var OP = {};

OP.diffString = function(oldval, newval) {
  var changes, commonEnd, commonStart, k, l, minLength, ref, ref1;
  if (oldval === newval) {
    return [];
  }
  minLength = Math.min(oldval.length, newval.length);
  for (commonStart = k = 0, ref = minLength; 0 <= ref ? k < ref : k > ref; commonStart = 0 <= ref ? ++k : --k) {
    if (oldval.charAt(commonStart) !== newval.charAt(commonStart)) {
      break;
    }
  }
  for (commonEnd = l = 0, ref1 = minLength - commonStart; 0 <= ref1 ? l < ref1 : l > ref1; commonEnd = 0 <= ref1 ? ++l : --l) {
    if (oldval.charAt(oldval.length - 1 - commonEnd) !== newval.charAt(newval.length - 1 - commonEnd)) {
      break;
    }
  }
  changes = [];
  if (oldval.length !== (commonStart + commonEnd)) {
    changes.push({
      t: 'r',
      s: commonStart,
      e: oldval.length - commonEnd
    });
  }
  if (newval.length !== (commonStart + commonEnd)) {
    changes.push({
      t: 'i',
      s: commonStart,
      v: newval.slice(commonStart, newval.length - commonEnd)
    });
  }
  return changes;
};

OP.applyChanges = function(val, changes) {
  var change, k, len;
  for (k = 0, len = changes.length; k < len; k++) {
    change = changes[k];
    switch (change.t) {
      case 'r':
        val = val.substr(0, change.s) + val.substr(change.e);
        break;
      case 'i':
        val = val.substr(0, change.s) + change.v + val.substr(change.s);
    }
  }
  return val;
};
