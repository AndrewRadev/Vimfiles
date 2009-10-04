" Managing urls (and more):
command! -bar -nargs=1 OpenURL :Utl openLink <args>
nmap gu :Utl<cr>

" Utl media handlers:
if has('win32')
  let g:utl_cfg_hdl_mt_generic = 'silent !cmd /q /c start "dummy title" "%P"'
  let g:utl_cfg_hdl_mt_text_directory = ':!start explorer "%P"'
else
  " Generic handler doesn't work without a desktop...
  " Open directories:
  let g:utl_cfg_hdl_mt_text_directory = ':!thunar %p &> /dev/null &'
  " Applications:
  let g:utl_cfg_hdl_mt_application_pdf     = ':!evince  %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_application_zip     = ':!squeeze %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_application_x_gzip  = ':!squeeze %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_application_x_bzip2 = ':!squeeze %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_application_excel   = ':!soffice %p &> /dev/null &'
  " Images:
  let g:utl_cfg_hdl_mt_image_generic = ':!gliv %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_image_png     = ':!gliv %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_image_jpeg    = ':!gliv %p &> /dev/null &'
  let g:utl_cfg_hdl_mt_image_gif     = ':!gliv %p &> /dev/null &'
  " Video:
  let g:utl_cfg_hdl_mt_video_x_msvideo = ':!smplayer %p &> /dev/null &'
endif
