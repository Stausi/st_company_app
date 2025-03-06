import React, { useEffect, useRef, useState, ReactNode } from 'react';
import Companies from './companies/Companies'
import CompanyInput from './company-input/CompanyInput'
import PlayerJob from './playerjob/PlayerJob'

import Post from './post/Post'
import CreatePost from './create-post/CreatePost'

import './App.css'
import Frame from './frame/Frame'

const devMode = !window?.['invokeNative'];
export const imageUrl = devMode ? "" : "/web/build";

export interface CompanyIF {
    name: string;
    icon: string;
    title: string;
    image: string;
    message: string;
    showStatus: boolean;
    status: boolean;
    isAdmin: boolean;
    isWorker: boolean;
    hasSub: boolean;
    hasJob: boolean;
    disableResign: boolean;
    job: string;
}

export interface PostIF {
    image: string;
    title: string;
    message: string;
    name: string;
    icon: string;
    isAdmin: boolean;
}

interface Overview {
    name: string;
    grade: string;
    jobs: CompanyIF[];
    admin: boolean;
}

const App = () => {
    const [AppPage, setAppPage] = useState<string>("overview");
    const [transitioning, setTransitioning] = useState<Boolean>(false);

    const [refreshKey, setRefreshKey] = useState(0);
    const [company, setCompany] = useState<number>(-1);
    const [companies, setCompanies] = useState<CompanyIF[]>([]);
    
    const [posts, setPosts] = useState<PostIF[]>([]);
    const [isCreatingPost, setIsCreatingPost] = useState<Boolean>(false);
    const [postImage, setPostImage] = useState<string>("");

    const [currentJob, setCurrentJob] = useState<string>("");
    const [currentGrade, setCurrentGrade] = useState<string>("");
    const [playerJobs, setPlayerJobs] = useState<CompanyIF[]>([]);
    const [playerAdmin, setPlayerAdmin] = useState<Boolean>(true);

    const updateCompany = (newCompanyValue: number) => {
        setTransitioning(true);

        setTimeout(() => {
            setCompany(newCompanyValue);
            setTransitioning(false);
        }, 300);
    };

    const enterCreatingPost = () => {
        if (!devMode) {
            components.setGallery({
                includeVideos: true,
                includeImages: true,
                allowExternal: true,
                multiSelect: false,

                onSelect(data) {
                    let src = Array.isArray(data) ? data[0].src : data.src;
                    setPostImage(src);
                    setIsCreatingPost(true);
                }
            });
        } else {
            setPostImage(`${imageUrl}/background.png`);
            setIsCreatingPost(true);
        }
    };

    const appDiv = useRef(null)
    useEffect(() => {
        if (devMode) {
            document.body.style.visibility = 'visible'
            return;
        }

        const setupPosts = async () => {
            if (devMode) return;

            let newPosts = await fetchNui<PostIF[]>("setupPosts", {});
            setPosts(newPosts);
        }

        const setupCompanies = async () => {
            if (devMode) return;

            let newCompanies = await fetchNui<CompanyIF[]>("setupApp", {});
            setCompanies(newCompanies);
        }

        const setupUserOverview = async () => {
            if (devMode) return;

            let overview = await fetchNui<Overview>("setupOverview", {});
            setCurrentJob(overview.name);
            setCurrentGrade(overview.grade);
            setPlayerJobs(overview.jobs);
            setPlayerAdmin(overview.admin);
        }

        const setUserOverview = (data: Overview) => {
            setCurrentJob(data.name);
            setCurrentGrade(data.grade);
            setPlayerJobs(data.jobs);
            setPlayerAdmin(data.admin);
        }

        useNuiEvent('refreshCompanies', setCompanies);
        useNuiEvent('refreshPosts', setPosts);
        useNuiEvent('refreshUser', setUserOverview);

        setupPosts();
        setupCompanies();
        setupUserOverview();
    }, [refreshKey]);

    const refreshApp = () => setRefreshKey(prevKey => prevKey + 1);
    useNuiEvent('appOpened', refreshApp);

    return (
        <AppProvider>
            <div className="app" ref={appDiv}>
                <div className='app-wrapper'>
                    <div className={`main-content ${transitioning ? "transitioning" : ""}`}>
                        {AppPage === "poster" && (
                            <>
                                <h1 className="headline">Firma Opslag</h1>
                                {!isCreatingPost && (
                                    <>
                                        {playerAdmin && (
                                            <div className="create-button">
                                                <button onClick={enterCreatingPost} className="create-post">
                                                    <i className="fa-solid fa-plus"></i> Opret opslag
                                                </button>
                                            </div>
                                        )}
                                        <div className="company-posts">
                                            {posts.map((post, index) => (
                                                <Post key={index} index={index} post={post} />
                                            ))}
                                        </div>
                                    </>
                                )}
                                {isCreatingPost && (
                                    <>
                                        <div className="create-button">
                                            <button onClick={() => setIsCreatingPost(false)} className="create-post">
                                                <i className="fa-solid fa-backward-step"></i> Gå tilbage
                                            </button>
                                        </div>
                                        <div className="company-create-post">
                                            <CreatePost image={postImage} setIsCreatingPost={setIsCreatingPost} />
                                        </div>
                                    </>
                                )}
                            </>
                        )}
        
                        {AppPage === "companies" && (
                            <>
                                {companies[company] ? (
                                    <CompanyInput company={companies[company]} updateCompany={updateCompany} />
                                ) : (
                                    <>
                                        <h1 className="headline">Firmaer</h1>
                                        <Companies companies={companies} updateCompany={updateCompany} />
                                    </>
                                )}
                            </>
                        )}
        
                        {AppPage === "overview" && (
                            <>
                                <h1 className="headline">Oversigt</h1>
                                <div className="user-overview">
                                    <div className="user-overview-container">
                                        <h3>{currentJob}</h3>
                                        <h3>{currentGrade}</h3>
                                    </div>
                                </div>
                                <div className="player-jobs">
                                    {playerJobs.map((job, index) => (
                                        <PlayerJob key={index} job={job} />
                                    ))}
                                </div>
                            </>
                        )}
                    </div>
        
                    <footer className="footer">
                        <button onClick={() => {
                            setTransitioning(true);
                            setTimeout(() => {
                                setAppPage("overview");
                                setTransitioning(false);
                            }, 300);
                        }} className={`footer-button ${AppPage === "overview" ? "active" : ""}`} >
                            <i className="fa-solid fa-house"></i>
                            <p>Oversigt</p>
                        </button>

                        <button onClick={() => {
                            setTransitioning(true);
                            setTimeout(() => {
                                setAppPage("companies");
                                setTransitioning(false);
                            }, 300);
                        }} className={`footer-button ${AppPage === "companies" ? "active" : ""}`} >
                            <i className="fa-solid fa-building"></i>
                            <p>Firmaer</p>
                        </button>

                        <button onClick={() => {
                            setTransitioning(true);
                            setTimeout(() => {
                                setAppPage("poster");
                                setTransitioning(false);
                            }, 300);
                        }} className={`footer-button ${AppPage === "poster" ? "active" : ""}`} >
                            <i className="fa-solid fa-envelope"></i>
                            <p>Posters</p>
                        </button>
                    </footer>
                </div>
            </div>
        </AppProvider>
    )
}

const AppProvider = ({ children }: { children: ReactNode }) => {
    if (devMode) {
        const handleResize = () => {
            const { innerWidth, innerHeight } = window

            const aspectRatio = innerWidth / innerHeight
            const phoneAspectRatio = 27.6 / 59

            if (phoneAspectRatio < aspectRatio) {
                document.documentElement.style.fontSize = '1.66vh'
            } else {
                document.documentElement.style.fontSize = '3.4vw'
            }
        }

        useEffect(() => {
            window.addEventListener('resize', handleResize)

            return () => {
                window.removeEventListener('resize', handleResize)
            }
        }, [])

        handleResize()

        return (
            <div className="dev-wrapper">
                <Frame>{children}</Frame>
            </div>
        )
    } else return children
}

export default App;
