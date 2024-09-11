# May 06 - May 17
* Argo has been intergrated into AVP app
* Speech to text is working (still needs debugging)
    * Issues when trying to start up a second recording
* Text to speech working
* Started looking into UE5 and Unity for VR development
* Looked into building 3D mesh of protein-protein data

# May 20 - May 24
* Unity requires a pro license for visionOS development, so it has been dropped.
* UE5 was refusing to build and reported the following error:
**InvalidDataException: The archive entry was compressed using an unsupported compression method.**
Fixed it by changing 'http' to 'https' in the BaseURL in Engine/Build/Commit.gitdeps.xml [Source](https://forums.unrealengine.com/t/upcoming-disruption-of-service-impacting-unreal-engine-users-on-github/1155880/149)
* Got hand gestures working. Using hand gestures for basic commands
* Stores conversation with Argo, so we can have an on going conversation. (still needs work, continuesly mentions previous messages, even when not brought up)
* Successfully converted dot file to usdz and imported into Apple Reality Composer Pro.
* Started building interface for the string-db API

# May 27 - May 31
* Set up interface for Gecko, our protein visualization tool. We can now query the STRING-db with requests for data.
* Created functions that deal with meetings. It now transcribes, summarizes, and names them.
* Started working on functions to generate 3D models for protein data.
* Created features for meetings. Now keeps tracks, summarizes, and names meetings.

# June 03 - June 07
* Finished functions to create spheres for each protein returned by API request. 
* Finished tooltip-style description boxes for protein objects that appear when clicked on.
* Added edges to protein network
* Able to connect to Polaris via sending HTTP request to a server
* Working on GENIUS animation

# June 10 - June 14
* Setup "show me" command to use Sketchfab API to search for and choose a 3D model to open using Argo for decision-making
* Made single gesture to use while recording instead of seperate gestures for start and stop
* Made a working terminal in the app
* Began working on integrating Argo with the terminal

# June 17 - June 21
* Made window for displaying simulation video
* Ran benchmarks to compare Argo/GPT 3.5 vs Llama 3
    * Argo runs faster
    * Llama response is easier to manipulate (can tell it how to start or end response)
    
# June 24 - June 28
* Running jobs on Polaris and displaying results
    * Using LBM CFD sim
    * Able to display the results as a video
    * Created window to display simulation
* Made recording one held gesture instead of two for starting and stopping
* Error recovery and guiding the user 
* Getting protein objects to move around 3D space.
* Getting edges to follow protein movement.

# July 01 - July 05
* Able to submit jobs from the app
* Integrated Argo into running and modifying jobs
* More UI changes: Fonts, color schemes 
* Removing jitter from edge movement.

# July 08 - July 12
* Fixed small errors in running the simulation
* Integrated Argo to provide protein interaction partners.

# July 15 - July 19
* More UI changes
* Working on trying to convert a .vtu to a .usdz
* Adjusted simulation feature to allow adjustments of parameters before running the job

# July 22 - July 26
* Put a pause on trying to get a simulation that produces a 3D module working
* Working on making a calendar/scheduling feature
* Added clear all windows function

# July 29 - August 02
