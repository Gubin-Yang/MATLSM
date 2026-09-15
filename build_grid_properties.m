function grid = build_grid_properties(lat,lon)
%BUILD_GRID_PROPERTIES 一次性建立全项目共享的空间网格属性。
% 网格中心、二维经纬度、纬度弧度、CDT球面网格面积和地理陆地掩膜均在
% config阶段计算一次；后续forcing、static、assessment直接复用。

assert(exist('cdtarea','file')==2,'lsm:MissingCDT', ...
    '缺少Climate Data Toolbox函数cdtarea，请先安装CDT并加入MATLAB路径。');
assert(exist('island','file')==2,'lsm:MissingCDT', ...
    '缺少Climate Data Toolbox函数island，请先安装CDT并加入MATLAB路径。');

grid.lat = single(lat(:));
grid.lon = single(lon(:));
[grid.lon2,grid.lat2] = meshgrid(grid.lon,grid.lat);
grid.latr = deg2rad(double(grid.lat2));
grid.geographic_land_mask = logical(island(grid.lat2,grid.lon2));
grid.cell_area_km2 = single(cdtarea(grid.lat2,grid.lon2,'km2'));
grid.cell_area_m2 = grid.cell_area_km2.*single(1e6);

assert(isequal(size(grid.cell_area_km2),size(grid.lat2)) ...
    && all(isfinite(grid.cell_area_km2(:))) ...
    && all(grid.cell_area_km2(:)>0), ...
    'lsm:BadGridCellArea','cdtarea返回的网格面积缺失、非正或维度错误。');
end
