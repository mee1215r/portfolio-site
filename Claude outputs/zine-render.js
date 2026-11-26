/* ZINEのページに貼るもの(写真・ステッカー・文字・ペンの線)を描く。index.html と edit.html で共通。
   位置と大きさは、ページの横幅を100とした割合。縦は 133.3 まで(3:4のページ)。 */
(function(){
  var NS = 'http://www.w3.org/2000/svg';
  var css = document.createElement('style');
  css.textContent = [
    '.pg img.stk{position:absolute;inset:auto;height:auto;object-fit:fill;filter:drop-shadow(0 .7cqw 1.1cqw rgba(0,0,0,.28));-webkit-user-drag:none;user-select:none;pointer-events:none}',
    '.pg img.stk.pic{border:2.4cqw solid #fff;box-sizing:content-box;filter:drop-shadow(0 .6cqw 1cqw rgba(0,0,0,.3))}',
    '.pg .txt{position:absolute;margin:0;font-family:"Klee One","Zen Kaku Gothic New","Hiragino Maru Gothic ProN",sans-serif;font-weight:600;line-height:1.35;white-space:pre;pointer-events:none;user-select:none}',
    '.pg .tape{position:absolute;margin:0;opacity:.88;pointer-events:none;clip-path:polygon(0 8%,2% 0,4% 8%,6% 0,8% 8%,10% 0,100% 0,100% 100%,10% 100%,8% 92%,6% 100%,4% 92%,2% 100%,0 92%);mix-blend-mode:multiply;box-shadow:0 .3cqw .6cqw rgba(0,0,0,.18)}',
    '.pg svg.pen{position:absolute;left:0;top:0;width:100%;height:100%;pointer-events:none;overflow:visible}',
    '.pg.paper{background-color:#FBF8EE;background-image:repeating-linear-gradient(to bottom,transparent 0,transparent 4.05%,rgba(110,140,190,.42) 4.05%,rgba(110,140,190,.42) 4.2%)}'
  ].join('\n');
  document.head.appendChild(css);

  function pathD(p){
    if (!p.length) return '';
    if (p.length === 1) return 'M' + p[0][0] + ' ' + p[0][1] + 'l.01 0';
    var d = 'M' + p[0][0] + ' ' + p[0][1];
    for (var i = 1; i < p.length - 1; i++){
      var mx = (p[i][0] + p[i+1][0]) / 2, my = (p[i][1] + p[i+1][1]) / 2;
      d += 'Q' + p[i][0] + ' ' + p[i][1] + ' ' + mx.toFixed(2) + ' ' + my.toFixed(2);
    }
    var l = p[p.length - 1];
    return d + 'L' + l[0] + ' ' + l[1];
  }

  function item(t, hit){
    var n;
    if (t.pen){
      n = document.createElementNS(NS, 'svg');
      n.setAttribute('class', 'pen'); n.setAttribute('viewBox', '0 0 100 133.333'); n.setAttribute('preserveAspectRatio', 'none');
      n.setAttribute('aria-hidden', 'true');
      var d = pathD(t.pen);
      var p = document.createElementNS(NS, 'path');
      p.setAttribute('d', d); p.setAttribute('fill', 'none'); p.setAttribute('stroke', t.c || '#222');
      p.setAttribute('stroke-width', t.wd || .8); p.setAttribute('stroke-linecap', 'round'); p.setAttribute('stroke-linejoin', 'round');
      n.appendChild(p);
      if (hit){
        var h = document.createElementNS(NS, 'path');
        h.setAttribute('d', d); h.setAttribute('class', 'hit'); h.setAttribute('fill', 'none'); h.setAttribute('stroke', 'transparent');
        h.setAttribute('stroke-width', Math.max(t.wd || .8, 3)); h.setAttribute('stroke-linecap', 'round'); h.setAttribute('stroke-linejoin', 'round');
        n.appendChild(h);
      }
      return n;
    }
    if (t.tape){
      n = document.createElement('div'); n.className = 'tape';
      var c = t.c || '#F4A6B8', pat = t.pat || 'stripe';
      n.style.left = t.x + '%'; n.style.top = t.y + '%'; n.style.width = t.w + '%'; n.style.height = (t.w * .2) + 'cqw';
      if (pat === 'stripe') n.style.background = 'repeating-linear-gradient(135deg,' + c + ' 0,' + c + ' 1.4cqw,rgba(255,255,255,.7) 1.4cqw,rgba(255,255,255,.7) 2.8cqw)';
      else if (pat === 'dot') n.style.background = 'radial-gradient(rgba(255,255,255,.85) 22%,transparent 24%) 0 0/2.6cqw 2.6cqw,' + c;
      else n.style.background = c;
      if (t.r) n.style.transform = 'rotate(' + t.r + 'deg)';
      return n;
    }
    if (t.txt != null){
      n = document.createElement('div'); n.className = 'txt'; n.textContent = t.txt;
      n.style.left = t.x + '%'; n.style.top = t.y + '%'; n.style.fontSize = (t.size || 6) + 'cqw'; n.style.color = t.ink || '#2a2a2a';
      if (t.r) n.style.transform = 'rotate(' + t.r + 'deg)';
      return n;
    }
    n = document.createElement('img'); n.className = 'stk' + (t.pic ? ' pic' : '');
    n.src = t.src; n.alt = t.alt || ''; n.draggable = false;
    n.style.left = t.x + '%'; n.style.top = t.y + '%'; n.style.width = t.w + '%';
    if (t.r) n.style.transform = 'rotate(' + t.r + 'deg)';
    return n;
  }
  function addItems(pg, items, hit){
    var out = [];
    (items || []).forEach(function(t, i){ var n = item(t, hit); n.dataset.i = i; pg.appendChild(n); out.push(n); });
    return out;
  }
  window.ZR = { item: item, addItems: addItems };
})();
