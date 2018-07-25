<?php
$e = $modx->event;
$id = $e->params['id'];
$mode = $e->params['mode'];
$checkNav = (isset($_POST['stay']) && (strpos($_POST['stay'],'next') !== false || strpos($_POST['stay'],'prev') !== false));
if ($e->name == 'OnDocFormSave' && $mode == 'upd' && $checkNav) {
    $sd=isset($_POST['dir'])?'&dir='.$_POST['dir']:'&dir=DESC';
    $sb=isset($_POST['sort'])?'&sort='.$_POST['sort']:'&sort=pub_date';
    $pg=isset($_POST['page'])?'&page='.(int)$_POST['page']:'';
    $add_path=$sd.$sb.$pg;
    // secure web documents - flag as private
    include MODX_MANAGER_PATH . "includes/secure_web_documents.inc.php";
    secureWebDocument($id);
    // secure manager documents - flag as private
    include MODX_MANAGER_PATH . "includes/secure_mgr_documents.inc.php";
    secureMgrDocument($id);
    if (isset($_POST['syncsite']) && $_POST['syncsite'] == 1) {
        $modx->clearCache();
    }
    $id = substr($_POST['stay'], 4);
    $header = "Location: index.php?a=27&id=".$id."&r=1&stay=" . $_POST['stay'] . $add_path;
    header($header);
    //break;
}
if ($e->name == 'OnManagerMainFrameHeaderHTMLBlock' && isset($_REQUEST['id']) && ($_REQUEST['a'] == 3 || $_REQUEST['a'] == 27)) {
    $id = (int)$_REQUEST['id'];
    $parent = $modx->getDocument($id,'parent');
    if (!is_array($parent) || !isset($parent['parent'])) return;
    $parent= $parent['parent'];
    $upTitle = $modx->getDocument($parent,'pagetitle');
    $upTitle = $upTitle['pagetitle'];
    $docs = $modx->getDocumentChildren ($parent, 1, 0, 'id, pagetitle', '', $sortBy, 'ASC', '');
    foreach ($docs as $key=>$doc) {
        if ($doc['id'] == $id) $curKey = $key;
    }
    $curDoc = $docs[$curKey];
    if (($curKey+1) >= count($docs)) {
        if ($cycle=='Yes') {
            $next = $docs[0];
        }
        else {
            $next=$docs[$curKey];
        }
    } else {
        $next = $docs[$curKey+1];
    }
    if (($curKey-1) < 0) {
        if ($cycle=='Yes') {
            $prev = $docs[count($docs)-1];
        }
        else {
            $prev = $docs[$curKey];
        }
    } else {
        $prev = $docs[$curKey-1];
    }
    $stay = isset($_REQUEST['stay']);
    if ($stay) {
        $stay = substr($_REQUEST['stay'],0,1); 
        switch ($stay) {
            case 'n' : $selectNext = "stay.value='next" . $next['id'] . "';"; break;
            case 'p' : $selectPrev = "stay.value='prev" . $prev['id'] . "';"; break;
        }
    }
    $output = <<< OUT
<script type="text/javascript">
(function(){
function createBtn(icon,href,title) {
    var btn = document.createElement('a');
    btn.innerHTML = '<i class="fa '+icon+'" style="display:inline-block;"></i>';
    btn.href = href;
    btn.title = title;
    btn.className='btn btn-secondary';
    return btn;
}
function createOption(id, value, text) {
    var option = document.createElement('option');
    option.id = id;
    option.value = value;
    option.text = text;
    return option;
}
document.addEventListener('DOMContentLoaded', function() {
    if (typeof actionStay === 'undefined') {
        actionStay = [];
    }
    actionStay['staynext{$next['id']}'] = '<i class="fa fa-arrow-left"></i>';
    actionStay['stayprev{$prev['id']}'] = '<i class="fa fa-arrow-right"></i>';
    var prevBtn = createBtn('fa-arrow-left','index.php?a=27&id={$prev['id']}','{$prev['pagetitle']}');
    var upBtn = createBtn('fa-arrow-up','index.php?a=27&id={$parent}','{$upTitle}');
    var nextBtn = createBtn('fa-arrow-right','index.php?a=27&id={$next['id']}','{$next['pagetitle']}');
    var saveNextOption = createOption('staynext{$next['id']}', 'next{$next['id']}', 'К следующему');
    var savePrevOption = createOption('stayprev{$prev['id']}', 'prev{$prev['id']}', 'К предыдущему');

    var menu = document.querySelector('div#actions>.btn-group');
    var stay = document.getElementById('stay');
    if ({$id} !== {$prev['id']}) {
        menu.appendChild(prevBtn);
        stay.appendChild(savePrevOption);
        {$selectPrev}
    }
    if (0 !== {$parent}) menu.appendChild(upBtn);
    if ({$id} !== {$next['id']}) {
        menu.appendChild(nextBtn);
        stay.appendChild(saveNextOption);
        {$selectNext}
    }
    })
}());
</script>
<!-- /managerNav -->
OUT;
    $e->output($output);
}
