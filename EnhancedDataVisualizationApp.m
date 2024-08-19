classdef EnhancedDataVisualizationApp < matlab.apps.AppBase

    % 对应应用组件的属性
    properties (Access = public)
        UIFigure            matlab.ui.Figure           % 主界面窗口
        LoadDataButton      matlab.ui.control.Button   % 加载数据按钮
        GenerateReportButton matlab.ui.control.Button  % 生成报告按钮
        ExportReportButton  matlab.ui.control.Button   % 导出报告按钮
        DataTable           matlab.ui.control.Table    % 数据表格
        UIAxes1             matlab.ui.control.UIAxes   % 第一个图表区域
        UIAxes2             matlab.ui.control.UIAxes   % 第二个图表区域
        UIAxes3             matlab.ui.control.UIAxes   % 第三个图表区域
    end
    
    properties (Access = private)
        Data % 表格数据
    end

    % 处理组件事件的回调函数
    methods (Access = private)

        % 按钮按下函数：LoadDataButton
        function LoadDataButtonPushed(app, event)
            [file, path] = uigetfile({'*.csv'; '*.xlsx'}, '选择数据文件'); % 打开文件选择对话框
            if isequal(file, 0)
                return;
            end
            filePath = fullfile(path, file); % 获取文件路径
            [~, ~, ext] = fileparts(filePath);
            if strcmp(ext, '.csv')
                app.Data = readtable(filePath, 'VariableNamingRule', 'preserve'); % 读取CSV文件
            elseif strcmp(ext, '.xlsx')
                app.Data = readtable(filePath, 'Sheet', 1, 'VariableNamingRule', 'preserve'); % 读取Excel文件
            end
            
            % 确保列名是有效的MATLAB变量名
            app.Data.Properties.VariableNames = matlab.lang.makeValidName(app.Data.Properties.VariableNames);
            
            % 统一重命名列名
            app.Data.Properties.VariableNames = {'TradeDate', 'SettlementDate', 'Account', 'Code', 'Direction', 'Price', 'Quantity', 'Fee1', 'Fee2'};
            
            % 在表格中显示数据
            app.DataTable.Data = app.Data;
            % 显示加载成功消息
            uialert(app.UIFigure, '数据加载成功', '成功');
        end

        % 按钮按下函数：GenerateReportButton
        function GenerateReportButtonPushed(app, event)
            if isempty(app.Data)
                uialert(app.UIFigure, '请先加载数据', '错误'); % 提示先加载数据
                return;
            end

            % 数据可视化示例
            % 价格分布的直方图
            histogram(app.UIAxes1, app.Data.Price);
            title(app.UIAxes1, '价格分布', 'FontName', 'SimHei'); % 设置中文字体
            xlabel(app.UIAxes1, '价格', 'FontName', 'SimHei'); % 设置中文字体
            ylabel(app.UIAxes1, '频次', 'FontName', 'SimHei'); % 设置中文字体

            % 方向分布的柱状图
            directionCounts = groupcounts(app.Data.Direction);
            bar(app.UIAxes2, directionCounts);
            title(app.UIAxes2, '方向分布', 'FontName', 'SimHei'); % 设置中文字体
            xlabel(app.UIAxes2, '方向', 'FontName', 'SimHei'); % 设置中文字体
            ylabel(app.UIAxes2, '数量', 'FontName', 'SimHei'); % 设置中文字体

            % 代码类型的饼图
            [codeTypes, ~, idx] = unique(app.Data.Code);
            codeCounts = accumarray(idx, 1);
            pie(app.UIAxes3, codeCounts);
            title(app.UIAxes3, '代码类型饼状图', 'FontName', 'SimHei'); % 设置中文字体
        end

        % 按钮按下函数：ExportReportButton
        function ExportReportButtonPushed(app, event)
            if isempty(app.Data)
                uialert(app.UIFigure, '请先加载数据', '错误'); % 提示先加载数据
                return;
            end

            % 创建新的图窗用于导出
            fig = figure('Visible', 'off');
            t = tiledlayout(fig, 2, 2);
            
            % 价格分布的直方图
            nexttile(t);
            histogram(app.Data.Price);
            title('价格分布直方图', 'FontName', 'SimHei'); % 设置中文字体
            xlabel('价格', 'FontName', 'SimHei'); % 设置中文字体
            ylabel('频次', 'FontName', 'SimHei'); % 设置中文字体
            
            % 方向分布的柱状图
            nexttile(t);
            directionCounts = groupcounts(app.Data.Direction);
            bar(directionCounts);
            title('方向分布柱状图', 'FontName', 'SimHei'); % 设置中文字体
            xlabel('方向', 'FontName', 'SimHei'); % 设置中文字体
            ylabel('数量', 'FontName', 'SimHei'); % 设置中文字体
            
            % 代码类型的饼图
            nexttile(t);
            [codeTypes, ~, idx] = unique(app.Data.Code);
            codeCounts = accumarray(idx, 1);
            pie(codeCounts);
            title('代码类型饼状图', 'FontName', 'SimHei'); % 设置中文字体

            % 添加文本摘要
            nexttile(t);
            axis off; % 关闭坐标轴
            summaryText = sprintf('总交易数: %d\n总数量: %d\n总费用1: %.2f\n总费用2: %.2f', ...
                height(app.Data), sum(app.Data.Quantity), sum(app.Data.Fee1), sum(app.Data.Fee2));
            text(0.5, 0.5, summaryText, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontName', 'SimHei'); % 设置中文字体

            % 导出为PDF
            exportgraphics(t, 'Report.pdf', 'ContentType', 'vector');
            close(fig);

            % 显示导出成功消息
            uialert(app.UIFigure, '报告已导出为PDF格式，请在文件中查收', '成功');
        end
    end

    % 组件初始化
    methods (Access = private)

        % 创建UIFigure和组件
        function createComponents(app)

            % 创建UIFigure并隐藏，直到所有组件创建完成
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 800 600];
            app.UIFigure.Name = 'Enhanced Data Visualization App';

            % 创建LoadDataButton
            app.LoadDataButton = uibutton(app.UIFigure, 'push');
            app.LoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @LoadDataButtonPushed, true);
            app.LoadDataButton.Position = [20 550 100 22];
            app.LoadDataButton.Text = '加载数据';

            % 创建GenerateReportButton
            app.GenerateReportButton = uibutton(app.UIFigure, 'push');
            app.GenerateReportButton.ButtonPushedFcn = createCallbackFcn(app, @GenerateReportButtonPushed, true);
            app.GenerateReportButton.Position = [140 550 120 22];
            app.GenerateReportButton.Text = '综合报告';

            % 创建ExportReportButton
            app.ExportReportButton = uibutton(app.UIFigure, 'push');
            app.ExportReportButton.ButtonPushedFcn = createCallbackFcn(app, @ExportReportButtonPushed, true);
            app.ExportReportButton.Position = [280 550 100 22];
            app.ExportReportButton.Text = '输出报表';

            % 创建DataTable
            app.DataTable = uitable(app.UIFigure);
            app.DataTable.ColumnName = {'TradeDate', 'SettlementDate', 'Account', 'Code', 'Direction', 'Price', 'Quantity', 'Fee1', 'Fee2'};
            app.DataTable.RowName = {};
            app.DataTable.Position = [20 300 760 200];

            % 创建用于直方图的UIAxes
            app.UIAxes1 = uiaxes(app.UIFigure);
            app.UIAxes1.Position = [20 50 360 200];

            % 创建用于柱状图的UIAxes
            app.UIAxes2 = uiaxes(app.UIFigure);
            app.UIAxes2.Position = [400 50 180 200];

            % 创建用于饼图的UIAxes
            app.UIAxes3 = uiaxes(app.UIFigure);
            app.UIAxes3.Position = [600 50 180 200];

            % 显示所有组件创建完成后的窗口
            app.UIFigure.Visible = 'on';
        end
    end

    % 应用初始化和构造
    methods (Access = public)

        % 构造应用
        function app = EnhancedDataVisualizationApp

            % 创建和配置组件
            createComponents(app)

            % 向App Designer注册应用
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % 在应用删除前执行的代码
        function delete(app)

            % 删除应用时删除UIFigure
            delete(app.UIFigure)
        end
    end
end

