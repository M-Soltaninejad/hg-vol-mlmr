if not opt then

projectDir = projectDir or paths.concat(os.getenv('HOME'),'ears')

local function parse(arg)
    local cmd = torch.CmdLine()
    cmd:text()
    cmd:text(' ---------- General options ------------------------------------')
    cmd:text()
    cmd:option('-manualSeed',         -1, 'Manually set RNG seed')
    cmd:option('-GPU',                 1, 'Default preferred GPU, if set to -1: no GPU')
    cmd:option('-finalPredictions',false, 'Generate a final set of predictions at the end of training (default no)')
    cmd:option('-nThreads',            4, 'Number of data loading threads')
    cmd:option('-directory',          '', 'Number of data loading threads')
    cmd:text()
    cmd:text(' ---------- Model options --------------------------------------')
    cmd:text()
    cmd:option('-netType',       'mlmr-hg-vol', 'Model architecture')
    cmd:option('-model',           'none', 'Provide a path to a previously trained model')  -- none or snapshots*/model_**.t7
    cmd:option('-optimState',      'none', 'Provide a path to a previously used optim state') -- none  or  snapshots*/optimState_**.t7
    cmd:option('-nFeats',            128, 'Number of features in the hourglass') --256
    cmd:option('-nStack',              1, 'Number of hourglasses to stack')
    cmd:option('-nModules',            1, 'Number of residual modules at each location in the hourglass')
    cmd:text()
    cmd:text(' ---------- Snapshot options -----------------------------------')
    cmd:text()
    cmd:option('-snapshot',          10, 'How often to take a snapshot of the model (0 = never)')
    cmd:option('-saveInput',       false, 'Save input to the network (useful for debugging)')
    cmd:option('-saveHeatmaps',    false, 'Save output heatmaps')
    cmd:text()
    cmd:text(' ---------- Hyperparameter options -----------------------------')
    cmd:text()
    cmd:option('-LR',             2.5e-4, 'Learning rate')
    cmd:option('-LRdecay',           0.0, 'Learning rate decay')
    cmd:option('-momentum',          0.0, 'Momentum')
    cmd:option('-weightDecay',       0.0, 'Weight decay')
    cmd:option('-alpha',            0.99, 'Alpha')
    cmd:option('-LRStep',            200, 'Learning step rate')
    cmd:option('-LRStepGamma',       0.1, 'Learning step rate decay')
    cmd:option('-epsilon',          1e-8, 'Epsilon')
    cmd:option('-crit',            'BCE', 'Criterion type')
    cmd:option('-optMethod',   'rmsprop', 'Optimization method: rmsprop | sgd | nag | adadelta')
    cmd:option('-threshold',        .001, 'Threshold (on validation accuracy growth) to cut off training early')
    cmd:text()
    cmd:text(' ---------- Training options -----------------------------------')
    cmd:text()
    cmd:option('-nEpochs',           100, 'Total number of epochs to run')
    cmd:option('-trainBatch',          5, 'Mini-batch size')
    cmd:option('-validBatch',          1, 'Mini-batch size for validation')
    cmd:option('-validate',            5, 'How often to validate the model (0 = never)')
    cmd:option('-validateIterations',  2, 'How many epochs per validation')


    cmd:text()
    cmd:text(' ---------- Data options ---------------------------------------')
    cmd:text()
    cmd:option('-dataset',       'ctRoots', 'Input data set')
    cmd:option('-gen',             'gen', 'Path to save generated files')
    cmd:option('-captureResXY',       128, 'Input image crop resolution')
    cmd:option('-captureResZ',        128, 'Input image crop resolution')
    cmd:option('-inputResXY',         128, 'Input image scaled resolution')
    cmd:option('-inputResZ',          128, 'Input image scaled resolution')
    cmd:option('-outputResXY',        16, 'Output heatmap resolution')
    cmd:option('-outputResZ',         16, 'Output heatmap resolution')

    cmd:option('-scale',             .25, 'Degree of scale augmentation')
    cmd:option('-rotate',            .25, 'Degree of rotation augmentation')
    cmd:option('-randomCrop',          1, 'Perform random or centre crop to input size')
    cmd:option('-randomFlip',          1, 'Perform random horizontal flip half the time')
    cmd:option('-randomOffset',       8, 'Add random offset to image crop location')
    cmd:option('-hmGauss',             2, 'Heatmap gaussian size')

    local opt = cmd:parse(arg or {})
    return opt
end

-------------------------------------------------------------------------------
-- Process command line options
-------------------------------------------------------------------------------

opt = parse(arg)

if opt.GPU == -1 then
    nnlib = nn
else
    require 'cutorch'
    require 'cunn'
    require 'cudnn'
    nnlib = cudnn
    cutorch.setDevice(opt.GPU)
end

epoch = 1
opt.epochNumber = epoch

-- Track accuracy
opt.acc = {train={}, valid={}}

end
