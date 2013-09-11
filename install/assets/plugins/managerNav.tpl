//<?php
/**
 * managerNav
 * 
 * plugin to create links to next, previous and parent resource in manager
 *
 * @category 	plugin
 * @version 	1.0
 * @license 	http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @author      Pathologic (maxx@np.by)
 * @internal	@properties &sortBy=Field;text;menuindex &cycle=Cycle navigation;list;Yes,No;Yes 
 * @internal	@events OnDocFormRender
 * @internal    @installset base
 * @internal    @legacy_names managerNav
 */

$e = &$modx->Event;
$id = $e->params['id'];
if ($e->name == 'OnDocFormRender' && $id) {
$parent = $modx->getDocument($id,'parent');
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
var menu = $$('ul.actionButtons');
if ({$id} !== {$prev['id']}) menu[0].adopt(prevBtn);
if (0 !== {$parent}) menu[0].adopt(upBtn);
if ({$id} !== {$next['id']}) menu[0].adopt(nextBtn);
</script>
<!-- /managerNav -->
OUT;
$e->output($output);
}