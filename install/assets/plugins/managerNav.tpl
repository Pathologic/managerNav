//<?php
/**
 * managerNav
 * 
 * plugin to create links to next, previous and parent resource in manager
 *
 * @category 	plugin
 * @version 	1.1
 * @license 	http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @author      Pathologic (maxx@np.by)
 * @internal	@properties &sortBy=Field;text;menuindex &cycle=Cycle navigation;list;Yes,No;Yes 
 * @internal	@events OnDocFormRender
 * @internal    @installset base
 * @internal    @legacy_names managerNav
 */

$e = &$modx->Event;
$id = $e->params['id'];
$mode = $e->params['mode'];
$checkNav = (strpos($_POST['stay'],'next') !== FALSE || strpos($_POST['stay'],'prev') !==FALSE);
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

if ($_POST['syncsite'] == 1) {
		// empty cache
		include_once MODX_MANAGER_PATH . "processors/cache_sync.class.processor.php";
		$sync = new synccache();
		$sync->setCachepath(MODX_MANAGER_PATH . "../assets/cache/");
		$sync->setReport(false);
		$sync->emptyCache();
	}

$id = substr($_POST['stay'],4);
$header = "Location: index.php?a=27&id=".$id."&r=1&stay=" . $_POST['stay'] . $add_path;
header($header);
break;
}
if ($e->name == 'OnDocFormRender' && $id) {
$parent = $modx->getDocument($id,'parent');
$parent= $parent['parent'];
$upTitle = $modx->getDocument($parent,'pagetitle');
$upTitle = $upTitle['pagetitle'];
$lang['gotonext'] = 'К следующему';
$lang['gotoprev'] = 'К предыдущему';
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
}
else {
	$next = $docs[$curKey+1];
}
if (($curKey-1) < 0) {
	if ($cycle=='Yes') {
		$prev = $docs[count($docs)-1];
	}
	else {
		$prev = $docs[$curKey];
	}
}
else {
	$prev = $docs[$curKey-1];
}
$stay = isset($_GET['stay']);
if ($stay) {
	$stay = substr($_GET['stay'],0,1); 
	switch ($stay) {
		case 'n' : $selectNext = "$('stay').value='next" . $next['id'] . "';"; break;
		case 'p' : $selectPrev = "$('stay').value='prev" . $prev['id'] . "';"; break;
	}
}
$output = <<< OUT
<script type="text/javascript">
var prevBtn = new Element('li').adopt (new Element('a', {
	href: 'index.php?a=27&id={$prev['id']}'
	,title: '{$prev['pagetitle']}'
	}).setHTML('<img src="media/style/MODxRE/images/icons/prev.gif" />'));
var upBtn = new Element('li').adopt (new Element('a', {
	href: 'index.php?a=27&id={$parent}'
	,title: '{$upTitle}'
	}).setHTML('<img src="media/style/MODxRE/images/icons/arrow_up.png" />'));
var nextBtn = new Element('li').adopt (new Element('a', {
	href: 'index.php?a=27&id={$next['id']}'
	,title: '{$next['pagetitle']}'
	}).setHTML('<img src="media/style/MODxRE/images/icons/next.gif" />'));
	var saveNextOption = new Element('option').setProperty('value','next'+{$next['id']}).appendText('{$lang['gotonext']}');
	var savePrevOption = new Element('option').setProperty('value','prev'+{$prev['id']}).appendText('{$lang['gotoprev']}');
var menu = $$('ul.actionButtons');
if ({$id} !== {$prev['id']}) {
	menu[0].adopt(prevBtn);
	$('stay').adopt(savePrevOption);
	{$selectPrev}
}
if (0 !== {$parent}) menu[0].adopt(upBtn);
if ({$id} !== {$next['id']}) {
	menu[0].adopt(nextBtn);
	$('stay').adopt(saveNextOption);
	{$selectNext}
}
</script>
<!-- /managerNav -->
OUT;
$e->output($output);
}