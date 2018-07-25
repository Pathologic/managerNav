//<?php
/**
 * managerNav
 * 
 * plugin to create links to next, previous and parent resource in manager
 *
 * @category 	plugin
 * @version 	2.0
 * @license 	http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @author      Pathologic (m@xim.name)
 * @internal	@properties &sortBy=Field;text;menuindex &cycle=Cycle navigation;list;Yes,No;Yes 
 * @internal	@events OnManagerMainFrameHeaderHTMLBlock,OnDocFormSave
 * @internal    @installset base
 * @internal    @legacy_names managerNav
 */

return require MODX_BASE_PATH . 'assets/plugins/managerNav/plugin.managerNav.php';
