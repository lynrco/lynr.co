/**
 * Vow
 *
 * Copyright (c) 2012-2013 Filatov Dmitry (dfilatov@yandex-team.ru)
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * @version 0.3.0
 */(function(e){var t=function(e){this._res=e,this._isFulfilled=!!arguments.length,this._isRejected=!1,this._fulfilledCallbacks=[],this._rejectedCallbacks=[],this._progressCallbacks=[]};t.prototype={valueOf:function(){return this._res},isFulfilled:function(){return this._isFulfilled},isRejected:function(){return this._isRejected},isResolved:function(){return this._isFulfilled||this._isRejected},fulfill:function(e){if(this.isResolved())return;this._isFulfilled=!0,this._res=e,this._callCallbacks(this._fulfilledCallbacks,e),this._fulfilledCallbacks=this._rejectedCallbacks=this._progressCallbacks=r},reject:function(e){if(this.isResolved())return;this._isRejected=!0,this._res=e,this._callCallbacks(this._rejectedCallbacks,e),this._fulfilledCallbacks=this._rejectedCallbacks=this._progressCallbacks=r},notify:function(e){if(this.isResolved())return;this._callCallbacks(this._progressCallbacks,e)},then:function(e,n,r){var i=new t,s;return this._isRejected||(s={promise:i,fn:e},this._isFulfilled?this._callCallbacks([s],this._res):this._fulfilledCallbacks.push(s)),this._isFulfilled||(s={promise:i,fn:n},this._isRejected?this._callCallbacks([s],this._res):this._rejectedCallbacks.push(s)),this.isResolved()||this._progressCallbacks.push({promise:i,fn:r}),i},fail:function(e){return this.then(r,e)},always:function(e){var t=this,n=function(){return e(t)};return this.then(n,n)},progress:function(e){return this.then(r,r,e)},spread:function(e,t){return this.then(function(t){return e.apply(this,t)},t)},done:function(){this.fail(s)},delay:function(e){return this.then(function(n){var r=new t;return setTimeout(function(){r.fulfill(n)},e),r})},timeout:function(e){var n=new t,r=setTimeout(function(){n.reject(Error("timed out"))},e);return n.sync(this),n.always(function(){clearTimeout(r)}),n},sync:function(e){var t=this;e.then(function(e){t.fulfill(e)},function(e){t.reject(e)})},_callCallbacks:function(e,t){var r=e.length;if(!r)return;var s=this.isResolved(),u=this.isFulfilled();i(function(){var i=0,a,f,l;while(i<r){a=e[i++],f=a.promise,l=a.fn;if(o(l)){var c;try{c=l(t)}catch(h){f.reject(h);continue}s?n.isPromise(c)?function(e){c.then(function(t){e.fulfill(t)},function(t){e.reject(t)})}(f):f.fulfill(c):f.notify(c)}else s?u?f.fulfill(t):f.reject(t):f.notify(t)}})}};var n={promise:function(e){return arguments.length?this.isPromise(e)?e:new t(e):new t},when:function(e,t,n,r){return this.promise(e).then(t,n,r)},fail:function(e,t){return this.when(e,r,t)},always:function(e,t){return this.promise(e).always(t)},progress:function(e,t){return this.promise(e).progress(t)},spread:function(e,t,n){return this.promise(e).spread(t,n)},done:function(e){this.isPromise(e)&&e.done()},isPromise:function(e){return e&&o(e.then)},valueOf:function(e){return this.isPromise(e)?e.valueOf():e},isFulfilled:function(e){return this.isPromise(e)?e.isFulfilled():!0},isRejected:function(e){return this.isPromise(e)?e.isRejected():!1},isResolved:function(e){return this.isPromise(e)?e.isResolved():!0},fulfill:function(e){return this.when(e,r,function(e){return e})},reject:function(e){return this.when(e,function(e){var n=new t;return n.reject(e),n})},resolve:function(e){return this.isPromise(e)?e:this.when(e)},invoke:function(e){try{return this.promise(e.apply(null,u.call(arguments,1)))}catch(t){return this.reject(t)}},forEach:function(e,t,n,r){var i=r?r.length:e.length,s=0;while(s<i)this.when(e[r?r[s]:s],t,n),++s},all:function(e){var r=new t,i=f(e),s=i?l(e):c(e),o=s.length,u=i?[]:{};if(!o)return r.fulfill(u),r;var a=o,h=function(){if(!--a){var t=0;while(t<o)u[s[t]]=n.valueOf(e[s[t++]]);r.fulfill(u)}},p=function(e){r.reject(e)};return this.forEach(e,h,p,s),r},allResolved:function(e){var n=new t,r=f(e),i=r?l(e):c(e),s=i.length,o=r?[]:{};if(!s)return n.fulfill(o),n;var u=function(){--s||n.fulfill(e)};return this.forEach(e,u,u,i),n},any:function(e){var n=new t,r=e.length;if(!r)return n.reject(Error()),n;var i=0,s,o=function(e){n.fulfill(e)},u=function(e){i||(s=e),++i===r&&n.reject(s)};return this.forEach(e,o,u),n},delay:function(e,t){return this.promise(e).delay(t)},timeout:function(e,t){return this.promise(e).timeout(t)}},r,i=function(){if(typeof process=="object")return process.nextTick;if(e.setImmediate)return e.setImmediate;var t=[],n=function(){var e=t,n=0,r=t.length;t=[];while(n<r)e[n++]()};if(e.postMessage){var r=!0;if(e.attachEvent){var i=function(){r=!1};e.attachEvent("onmessage",i),e.postMessage("__checkAsync","*"),e.detachEvent("onmessage",i)}if(r){var s="__promise"+ +(new Date),o=function(e){e.data===s&&(e.stopPropagation&&e.stopPropagation(),n())};return e.addEventListener?e.addEventListener("message",o,!0):e.attachEvent("onmessage",o),function(n){t.push(n)===1&&e.postMessage(s,"*")}}}var u=e.document;if("onreadystatechange"in u.createElement("script")){var a=function(){var e=u.createElement("script");e.onreadystatechange=function(){e.parentNode.removeChild(e),e=e.onreadystatechange=null,n()},(u.documentElement||u.body).appendChild(e)};return function(e){t.push(e)===1&&a()}}return function(e){setTimeout(e,0)}}(),s=function(e){i(function(){throw e})},o=function(e){return typeof e=="function"},u=Array.prototype.slice,a=Object.prototype.toString,f=Array.isArray||function(e){return a.call(e)==="[object Array]"},l=function(e){var t=[],n=0,r=e.length;while(n<r)t.push(n++);return t},c=Object.keys||function(e){var t=[];for(var n in e)e.hasOwnProperty(n)&&t.push(n);return t};typeof exports=="object"?module.exports=n:typeof define=="function"?define(function(e,t,r){r.exports=n}):e.Vow=n})(this);