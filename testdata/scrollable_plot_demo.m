function scrollable_plot_demo()
    % 1. Generate sample data
    x = 0:0.01:100;
    y = sin(x) + randn(size(x))*0.1;
    
    % 2. Define window configurations
    window_size = 10; 
    max_x = max(x);
    min_x = min(x);

    % 3. Create the figure and plot
    fig = figure('Name', 'Scrollable Plot', 'Position', [100, 100, 800, 500]);
    ax = axes('Parent', fig, 'Position', [0.1, 0.2, 0.8, 0.7]);
    plot(ax, x, y, 'b-', 'LineWidth', 1.5);
    grid on;
    
    % Set initial visible x-axis limits
    xlim(ax, [min_x, min_x + window_size]);

    % 4. Create the scrollbar slider
    % Slider range maps to the starting x-value of your viewing window
    slider_max = max_x - window_size; 
    
    uicontrol('Parent', fig, ...
        'Style', 'slider', ...
        'Units', 'normalized', ...
        'Position', [0.1, 0.05, 0.8, 0.05], ...
        'Min', min_x, ...
        'Max', slider_max, ...
        'Value', min_x, ...
        'SliderStep', [0.01, 0.1], ...
        'Callback', @(src, event) scroll_callback(src, ax, window_size));
end

% 5. Callback function to update the view limits
function scroll_callback(slider_handle, target_axes, window_size)
    start_x = get(slider_handle, 'Value');
    xlim(target_axes, [start_x, start_x + window_size]);
end
