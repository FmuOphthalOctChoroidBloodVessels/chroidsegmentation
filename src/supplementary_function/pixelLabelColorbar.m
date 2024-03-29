function pixelLabelColorbar(cmap,classNames)
%分類するクラスに対応するcolorbarを追加します。

colormap(gca,cmap)
c = colorbar('peer', gca);
c.TickLabels = classNames;
numClasses = size(cmap,1);
c.Ticks = 1/(numClasses*2):1/numClasses:1;
c.TickLength = 0;
end