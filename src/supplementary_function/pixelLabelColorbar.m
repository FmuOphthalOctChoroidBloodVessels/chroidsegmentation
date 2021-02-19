function pixelLabelColorbar(cmap,classNames)
%•ª—Ş‚·‚éƒNƒ‰ƒX‚É‘Î‰‚·‚écolorbar‚ğ’Ç‰Á‚µ‚Ü‚·B

colormap(gca,cmap)
c = colorbar('peer', gca);
c.TickLabels = classNames;
numClasses = size(cmap,1);
c.Ticks = 1/(numClasses*2):1/numClasses:1;
c.TickLength = 0;
end