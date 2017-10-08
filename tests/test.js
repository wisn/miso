function getMountPoint () { return document.getElementById('miso-tests'); }
function clearMountPoint () { getMountPoint().innerHTML = ''; }
function vtext (txt) { return { type : "vtext", text : txt }; }
function vnode (props, css, children, key) {
  return { type : "vnode"
         , props : props
         , css : css
         , children : children
         , key : key
         };
}

QUnit.test( "Base case, diffing null objects should do nothing", function( assert ) {
  var a = null, b = null;
  diff(a,b, getMountPoint());
  assert.ok( a === null && b == null, "Passed!" );
  clearMountPoint ();
});

QUnit.test( "Should create a text node", function( assert ) {
  clearMountPoint ();
  mount = getMountPoint ();
  a = vtext("foo")
  diff(null, a, mount);
  assert.ok(a.domRef !== null, "DOM ref was populated" );
  assert.ok(getMountPoint().firstChild === a.domRef, "Placed appropriately on DOM" );
  assert.ok(a.domRef.textContent === "foo", "Correct text content was set");
  clearMountPoint ();
});
