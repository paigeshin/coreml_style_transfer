import turicreate as tc 

tc.config.set_num_gpus(0)

styles = tc.load_images('style/')
content = tc.load_images('content/')

model = tc.style_transfer.create(styles, content, max_iterations=6000)

test_images = tc.load_images('test/')

stylized_images = model.stylize(test_images, max_size=1024)

stylized_images.explore() 

model.export_coreml('MyCustomStyleTransfer.mlmodel')