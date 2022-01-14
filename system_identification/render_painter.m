function render_painter(displ_file)
if nargin > 0
%     render("..\..\Caltrans\cache\Caltrans.Painter.json", " -opainter.html", displ_file);
%     render ..\..\Caltrans\cache\Caltrans.Painter.json"  displ.json " -opainter.html" 
else
% render("..\..\Caltrans\cache\Caltrans.Painter.json", " -opainter.html");
    render ..\..\Caltrans\cache\Caltrans.Painter.json  -opainter.html
end
web(['file:///' fullfile(pwd, 'painter.html')])
end