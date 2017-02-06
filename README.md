# Dock-net
This is the implementation of our work - 'Learning Deep Representations and Detection of Docking Stations Using Underwater Imaging'.
##Prerequisite: Programs have been tested on Matlab 2016a. And (Matconvnet)[http://www.vlfeat.org/matconvnet/] ims neccessary to run this work.
##Run the code:
	1. Test
		* Please run './Train_and_Test_program/my_detection_test_demo.m'. 
		* Detection results will be saved in './test_samples/results'.

	2. Data augmentation
		* Please run './Docking_dataaug_program_upload/main.m'.
		* Select the datasets through the popping dialog box.
		* The images after data augmentation will be saved in the same directory as the datasets.
		* Three files can be obtained after augmentation: proposals_train.mat,proposals_test.mat and docking_imdb.mat.

	3. Training
		* When training is neccesary, please first finish step 2 data augmentation.
		* Please copy  docking_imdb.mat  obtained by augmentation to './data/'. Copy proposals_train.mat and proposals_test.mat to './data/SSW/'.
		* Please run './Train_and_Test_program/fast_rcnn_train.m'.
		* The model after training is named by 'net-deployed.mat' and saved in './data/'


