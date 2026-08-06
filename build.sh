#!/bin/bash
# Build script: converts .txt volumes into HTML pages
set -e

SRC="../"
DST="."
CSS="style.css"
SITE_TITLE="闭上眼睛的话就不害怕了"
SITE_TITLE_DISPLAY="闭上眼睛的话，就不害怕了"

# Array of volume files in order
vols=(
  "第一卷_雾"
  "第二卷_你身上的空洞太明显了"
  "第三卷_他不问因为怕自己也要回答"
  "第四卷_完美是杀死了自己之后剩下的空壳"
  "第五卷_白昼太轻了轻到不需要用力"
  "第六卷_同一双手不同的骨头"
  "第七卷_她后退了一步但不是恶意"
  "第八卷_接住全部或者不接"
  "第九卷_他说我不是好了是粘起来了"
  "第十卷_动摇的夜里姑母放了一杯热水"
  "第十一卷_旧报纸只有三行字"
  "第十二卷_他把线索递给她像交出一个自己"
  "第十三卷_堤防上手放在手旁边"
)

# Build volume pages
for i in "${!vols[@]}"; do
  idx=$((i+1))
  num=$(printf "%02d" $idx)
  fname="${vols[$i]}"
  srcfile="${SRC}${SITE_TITLE}_${fname}.txt"
  dstfile="${DST}/vol-${num}.html"

  # Extract vol number and title from vol name (e.g. "第一卷_雾" -> num="第一卷", title="雾")
  vnum=$(echo "$fname" | cut -d_ -f1)
  vtitle=$(echo "$fname" | cut -d_ -f2-)

  # Previous/Next links
  if [ $idx -eq 1 ]; then prev_link=""; else prev_idx=$((idx-1)); prev_num=$(printf "%02d" $prev_idx); prev_link="<a href=\"vol-${prev_num}.html\">← 上一卷</a>"; fi
  if [ $idx -eq 13 ]; then next_link=""; else next_idx=$((idx+1)); next_num=$(printf "%02d" $next_idx); next_link="<a href=\"vol-${next_num}.html\">下一卷 →</a>"; fi

  cat > "$dstfile" <<HTMLEOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${SITE_TITLE_DISPLAY} ·${vnum} ${vtitle}</title>
<link rel="stylesheet" href="${CSS}">
</head>
<body>

<nav class="topbar">
  <a href="index.html">目录</a>
  <span class="sep">/</span>
  <span style="font-size:0.82rem;color:var(--text-dim);">${vnum}</span>
</nav>

<div class="vol-page">
  <div class="vol-header">
    <div class="vol-num">${vnum}</div>
    <h1 class="vol-title">${vtitle}</h1>
  </div>
  <div class="prose">
HTMLEOF

  # Read the source file, skip first 2 lines (main title + volume header), process content
  # Wrap non-empty lines in <p>, add section breaks for 【X】 markers
  tail -n +3 "$srcfile" | awk -v idx="$idx" -v vtitle="$vtitle" '
  BEGIN { para=""; first=1 }
  /^【.*】$/ {
    if(para != "") { print "<p>" para "</p>"; para="" }
    print "<div class=\"section-break\">" $0 "</div>"
    next
  }
  /^[[:space:]]*$/ {
    if(para != "") { print "<p>" para "</p>"; para="" }
    next
  }
  /^第.*卷.*完$/ || /^第.*卷.*全书完$/ {
    if(para != "") { print "<p>" para "</p>"; para="" }
    next
  }
  {
    if(para == "") { para = $0 }
    else { para = para $0 }
  }
  END { if(para != "") { print "<p>" para "</p>" } }
  ' >> "$dstfile"

  cat >> "$dstfile" <<HTMLEOF
  </div>

  <nav class="vol-nav">
    <span>${prev_link}</span>
    <a href="index.html" class="toc-link">目录</a>
    <span>${next_link}</span>
  </nav>
</div>

<footer class="site-footer">
  <p>${SITE_TITLE_DISPLAY} · ${vnum} ${vtitle} · 完</p>
</footer>

</body>
</html>
HTMLEOF

  echo "  Built vol-${num}.html"
done

echo "Done! All 13 volumes generated."
