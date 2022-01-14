function render_painter(displ)
render("..\..\Caltrans\cache\Caltrans.Painter.json", "-opainter.html");
web(["file:///" fullfile("painter.html")])
end