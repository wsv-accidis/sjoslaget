/****** Object:  Table [Booking]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Booking](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[EventId] [uniqueidentifier] NOT NULL,
	[Reference] [nvarchar](8) NOT NULL,
	[FirstName] [nvarchar](64) NOT NULL,
	[LastName] [nvarchar](64) NOT NULL,
	[Email] [nvarchar](64) NOT NULL,
	[PhoneNo] [nvarchar](64) NOT NULL,
	[TeamName] [nvarchar](64) NOT NULL,
	[GroupName] [nvarchar](64) NOT NULL,
	[SpecialRequest] [nvarchar](2048) NOT NULL,
	[InternalNotes] [nvarchar](2048) NOT NULL,
	[Discount] [tinyint] NOT NULL,
	[TotalPrice] [decimal](8, 2) NOT NULL,
	[CandidateId] [uniqueidentifier] NULL,
	[QueueNo] [int] NOT NULL,
	[IsLocked] [bit] NOT NULL,
	[ConfirmationSent] [datetime2](3) NULL,
	[Created] [datetime2](3) NOT NULL,
	[Updated] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_Booking] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_Booking_Reference] UNIQUE NONCLUSTERED 
(
	[Reference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BookingAllocation]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingAllocation](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[BookingId] [uniqueidentifier] NOT NULL,
	[CabinId] [uniqueidentifier] NOT NULL,
	[NumberOfPax] [int] NOT NULL,
	[Note] [nvarchar](512) NOT NULL,
 CONSTRAINT [PK_BookingAllocation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BookingCandidate]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingCandidate](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[FirstName] [nvarchar](64) NOT NULL,
	[LastName] [nvarchar](64) NOT NULL,
	[Email] [nvarchar](64) NOT NULL,
	[PhoneNo] [nvarchar](64) NOT NULL,
	[TeamName] [nvarchar](64) NOT NULL,
	[TeamSize] [tinyint] NOT NULL,
	[GroupName] [nvarchar](64) NOT NULL,
	[Created] [datetime2](3) NOT NULL,
	[KeepAlive] [datetime2](3) NOT NULL,
	[DeleteProtected] [bit] NOT NULL,
 CONSTRAINT [PK_BookingCandidate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BookingCandidateChallenge]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingCandidateChallenge](
	[CandidateId] [uniqueidentifier] NOT NULL,
	[ChallengeId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_BookingCandidateChallenge] PRIMARY KEY CLUSTERED 
(
	[CandidateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BookingPax]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingPax](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[BookingId] [uniqueidentifier] NOT NULL,
	[FirstName] [nvarchar](256) NOT NULL,
	[LastName] [nvarchar](256) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[Dob] [nchar](6) NOT NULL,
	[Food] [nchar](1) NOT NULL,
	[CabinClassMin] [int] NOT NULL,
	[CabinClassPreferred] [int] NOT NULL,
	[CabinClassMax] [int] NOT NULL,
	[Order] [tinyint] NOT NULL,
 CONSTRAINT [PK_BookingPax] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BookingPayment]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingPayment](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[BookingId] [uniqueidentifier] NOT NULL,
	[Amount] [decimal](8, 2) NOT NULL,
	[Created] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_BookingPayment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BookingQueue]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BookingQueue](
	[No] [int] IDENTITY(1,1) NOT NULL,
	[CandidateId] [uniqueidentifier] NOT NULL,
	[Created] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_BookingQueue] PRIMARY KEY CLUSTERED 
(
	[No] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CabinClass]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CabinClass](
	[No] [int] NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[Description] [nvarchar](1024) NOT NULL,
 CONSTRAINT [PK_CabinClass] PRIMARY KEY CLUSTERED 
(
	[No] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Challenge]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Challenge](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Challenge] [nvarchar](64) NOT NULL,
	[Response] [nvarchar](64) NOT NULL,
 CONSTRAINT [PK_Challenge] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DayBooking]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DayBooking](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[EventId] [uniqueidentifier] NOT NULL,
	[Reference] [nvarchar](8) NOT NULL,
	[FirstName] [nvarchar](64) NOT NULL,
	[LastName] [nvarchar](64) NOT NULL,
	[Email] [nvarchar](64) NOT NULL,
	[PhoneNo] [nvarchar](64) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[Dob] [nchar](6) NOT NULL,
	[Food] [nchar](1) NOT NULL,
	[TypeId] [uniqueidentifier] NOT NULL,
	[PaymentConfirmed] [bit] NOT NULL,
	[ConfirmationSent] [datetime2](3) NULL,
	[Created] [datetime2](3) NOT NULL,
	[Updated] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_DayBooking] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_DayBooking_Reference] UNIQUE NONCLUSTERED 
(
	[Reference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [DayBookingType]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [DayBookingType](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Title] [nvarchar](64) NOT NULL,
	[IsMember] [bit] NOT NULL,
	[Price] [decimal](8, 2) NOT NULL,
	[Order] [int] NOT NULL,
 CONSTRAINT [PK_DayBookingType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Event]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Event](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsLocked] [bit] NOT NULL,
	[Opening] [datetime2](3) NULL,
	[Capacity] [int] NOT NULL,
 CONSTRAINT [PK_Event] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [EventCabinClass]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventCabinClass](
	[No] [int] NOT NULL,
	[EventId] [uniqueidentifier] NOT NULL,
	[PricePerPax] [decimal](8, 2) NOT NULL,
 CONSTRAINT [PK_EventCabinClass] PRIMARY KEY CLUSTERED 
(
	[No] ASC,
	[EventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [EventCabinClassDetail]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventCabinClassDetail](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[EventId] [uniqueidentifier] NOT NULL,
	[Title] [nvarchar](64) NOT NULL,
	[No] [int] NOT NULL,
	[Capacity] [int] NOT NULL,
	[Count] [int] NOT NULL,
 CONSTRAINT [PK_EventCabinClassDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Log]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Log](
	[Idx] [int] IDENTITY(1,1) NOT NULL,
	[Timestamp] [datetime] NOT NULL,
	[Level] [nvarchar](16) NOT NULL,
	[Logger] [nvarchar](64) NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[Callsite] [nvarchar](max) NULL,
	[Exception] [nvarchar](max) NULL,
	[UserName] [nvarchar](16) NULL,
	[Method] [nvarchar](8) NULL,
	[Url] [nvarchar](max) NULL,
	[RemoteAddress] [nvarchar](64) NULL,
	[LocalAddress] [nvarchar](64) NULL,
 CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED 
(
	[Idx] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Post]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Post](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	[ContentHtml] [nvarchar](max) NOT NULL,
	[Created] [datetime2](3) NOT NULL,
	[Updated] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_Post] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [PostImage]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PostImage](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[PostId] [uniqueidentifier] NOT NULL,
	[Data] [varbinary](max) NOT NULL,
	[MediaType] [nvarchar](32) NOT NULL,
	[Created] [datetime2](3) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [User]    Script Date: 2025-03-04 23:36:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [User](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[UserName] [nvarchar](16) NOT NULL,
	[PasswordHash] [nvarchar](1024) NOT NULL,
	[SecurityStamp] [nvarchar](1024) NOT NULL,
	[ResetToken] [nvarchar](1024) NULL,
	[IsBooking] [bit] NOT NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UK_User_UserName] UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Booking_CandidateId]    Script Date: 2025-03-04 23:36:25 ******/
CREATE NONCLUSTERED INDEX [IX_Booking_CandidateId] ON [Booking]
(
	[CandidateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Booking_EventId]    Script Date: 2025-03-04 23:36:25 ******/
CREATE NONCLUSTERED INDEX [IX_Booking_EventId] ON [Booking]
(
	[EventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BookingAllocation_BookingId]    Script Date: 2025-03-04 23:36:25 ******/
CREATE NONCLUSTERED INDEX [IX_BookingAllocation_BookingId] ON [BookingAllocation]
(
	[BookingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BookingPax_BookingId]    Script Date: 2025-03-04 23:36:25 ******/
CREATE NONCLUSTERED INDEX [IX_BookingPax_BookingId] ON [BookingPax]
(
	[BookingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [UK_BookingQueue]    Script Date: 2025-03-04 23:36:25 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UK_BookingQueue] ON [BookingQueue]
(
	[CandidateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DayBooking_Event]    Script Date: 2025-03-04 23:36:25 ******/
CREATE NONCLUSTERED INDEX [IX_DayBooking_Event] ON [DayBooking]
(
	[EventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventCabinClassDetail_EventId]    Script Date: 2025-03-04 23:36:25 ******/
CREATE NONCLUSTERED INDEX [IX_EventCabinClassDetail_EventId] ON [EventCabinClassDetail]
(
	[EventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Post_Created_Desc]    Script Date: 2025-03-04 23:36:25 ******/
CREATE NONCLUSTERED INDEX [IX_Post_Created_Desc] ON [Post]
(
	[Created] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_PostImage_PostId]    Script Date: 2025-03-04 23:36:25 ******/
CREATE NONCLUSTERED INDEX [IX_PostImage_PostId] ON [PostImage]
(
	[PostId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_GroupName]  DEFAULT ('') FOR [GroupName]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_SpecialRequests]  DEFAULT ('') FOR [SpecialRequest]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_InternalNotes]  DEFAULT ('') FOR [InternalNotes]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_Discount]  DEFAULT ((0)) FOR [Discount]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_TotalPrice]  DEFAULT ((0)) FOR [TotalPrice]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_IsLocked]  DEFAULT ((0)) FOR [IsLocked]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE [Booking] ADD  CONSTRAINT [DF_Booking_Updated]  DEFAULT (sysdatetime()) FOR [Updated]
GO
ALTER TABLE [BookingAllocation] ADD  CONSTRAINT [DF_BookingAllocation_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [BookingCandidate] ADD  CONSTRAINT [DF_BookingCandidate_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [BookingCandidate] ADD  CONSTRAINT [DF_BookingCandidate_GroupName]  DEFAULT ('') FOR [GroupName]
GO
ALTER TABLE [BookingCandidate] ADD  CONSTRAINT [DF_BookingCandidate_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE [BookingCandidate] ADD  CONSTRAINT [DF_BookingCandidate_KeepAlive]  DEFAULT (sysdatetime()) FOR [KeepAlive]
GO
ALTER TABLE [BookingCandidate] ADD  CONSTRAINT [DF_BookingCandidate_DeleteProtected]  DEFAULT ((0)) FOR [DeleteProtected]
GO
ALTER TABLE [BookingPax] ADD  CONSTRAINT [DF_BookingPax_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [BookingPayment] ADD  CONSTRAINT [DF_BookingPayment_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [BookingPayment] ADD  CONSTRAINT [DF_BookingPayment_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE [BookingQueue] ADD  CONSTRAINT [DF_BookingQueue_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE [Challenge] ADD  CONSTRAINT [DF_Challenge_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [DayBooking] ADD  CONSTRAINT [DF_DayBooking_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [DayBooking] ADD  CONSTRAINT [DF_DayBooking_PaymentConfirmed]  DEFAULT ((0)) FOR [PaymentConfirmed]
GO
ALTER TABLE [DayBooking] ADD  CONSTRAINT [DF_DayBooking_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE [DayBooking] ADD  CONSTRAINT [DF_DayBooking_Updated]  DEFAULT (sysdatetime()) FOR [Updated]
GO
ALTER TABLE [DayBookingType] ADD  CONSTRAINT [DF_DayBookingType_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [DayBookingType] ADD  CONSTRAINT [DF_DayBookingType_Order]  DEFAULT ((0)) FOR [Order]
GO
ALTER TABLE [Event] ADD  CONSTRAINT [DF_Event_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [Event] ADD  CONSTRAINT [DF_Event_IsLocked]  DEFAULT ((0)) FOR [IsLocked]
GO
ALTER TABLE [Event] ADD  CONSTRAINT [DF_Event_Capacity]  DEFAULT ((1000)) FOR [Capacity]
GO
ALTER TABLE [EventCabinClassDetail] ADD  CONSTRAINT [DF_EventCabinClassDetail_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [Post] ADD  CONSTRAINT [DF_Post_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [Post] ADD  CONSTRAINT [DF_Post_ContentHtml]  DEFAULT ('') FOR [ContentHtml]
GO
ALTER TABLE [Post] ADD  CONSTRAINT [DF_Post_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE [Post] ADD  CONSTRAINT [DF_Post_Updated]  DEFAULT (sysdatetime()) FOR [Updated]
GO
ALTER TABLE [PostImage] ADD  CONSTRAINT [DF_PostImage_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [PostImage] ADD  CONSTRAINT [DF_PostImage_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE [User] ADD  CONSTRAINT [DF_User_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [User] ADD  CONSTRAINT [DF_User_PasswordHash]  DEFAULT ('') FOR [PasswordHash]
GO
ALTER TABLE [User] ADD  CONSTRAINT [DF_User_SecurityStamp]  DEFAULT ('') FOR [SecurityStamp]
GO
ALTER TABLE [User] ADD  CONSTRAINT [DF_User_IsBooking]  DEFAULT ((0)) FOR [IsBooking]
GO
ALTER TABLE [Booking]  WITH CHECK ADD  CONSTRAINT [FK_Booking_Booking] FOREIGN KEY([Id])
REFERENCES [Booking] ([Id])
GO
ALTER TABLE [Booking] CHECK CONSTRAINT [FK_Booking_Booking]
GO
ALTER TABLE [Booking]  WITH CHECK ADD  CONSTRAINT [FK_Booking_BookingCandidate] FOREIGN KEY([CandidateId])
REFERENCES [BookingCandidate] ([Id])
ON DELETE SET NULL
GO
ALTER TABLE [Booking] CHECK CONSTRAINT [FK_Booking_BookingCandidate]
GO
ALTER TABLE [Booking]  WITH CHECK ADD  CONSTRAINT [FK_Booking_Event] FOREIGN KEY([EventId])
REFERENCES [Event] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [Booking] CHECK CONSTRAINT [FK_Booking_Event]
GO
ALTER TABLE [BookingAllocation]  WITH CHECK ADD  CONSTRAINT [FK_BookingAllocation_Booking] FOREIGN KEY([BookingId])
REFERENCES [Booking] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [BookingAllocation] CHECK CONSTRAINT [FK_BookingAllocation_Booking]
GO
ALTER TABLE [BookingAllocation]  WITH CHECK ADD  CONSTRAINT [FK_BookingAllocation_EventCabinClassDetail] FOREIGN KEY([CabinId])
REFERENCES [EventCabinClassDetail] ([Id])
GO
ALTER TABLE [BookingAllocation] CHECK CONSTRAINT [FK_BookingAllocation_EventCabinClassDetail]
GO
ALTER TABLE [BookingCandidateChallenge]  WITH CHECK ADD  CONSTRAINT [FK_BookingCandidateChallenge_BookingCandidate] FOREIGN KEY([CandidateId])
REFERENCES [BookingCandidate] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [BookingCandidateChallenge] CHECK CONSTRAINT [FK_BookingCandidateChallenge_BookingCandidate]
GO
ALTER TABLE [BookingCandidateChallenge]  WITH CHECK ADD  CONSTRAINT [FK_BookingCandidateChallenge_Challenge] FOREIGN KEY([ChallengeId])
REFERENCES [Challenge] ([Id])
GO
ALTER TABLE [BookingCandidateChallenge] CHECK CONSTRAINT [FK_BookingCandidateChallenge_Challenge]
GO
ALTER TABLE [BookingPax]  WITH CHECK ADD  CONSTRAINT [FK_BookingPax_Booking] FOREIGN KEY([BookingId])
REFERENCES [Booking] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [BookingPax] CHECK CONSTRAINT [FK_BookingPax_Booking]
GO
ALTER TABLE [BookingPax]  WITH CHECK ADD  CONSTRAINT [FK_BookingPax_CabinClass_Max] FOREIGN KEY([CabinClassMax])
REFERENCES [CabinClass] ([No])
GO
ALTER TABLE [BookingPax] CHECK CONSTRAINT [FK_BookingPax_CabinClass_Max]
GO
ALTER TABLE [BookingPax]  WITH CHECK ADD  CONSTRAINT [FK_BookingPax_CabinClass_Min] FOREIGN KEY([CabinClassMin])
REFERENCES [CabinClass] ([No])
GO
ALTER TABLE [BookingPax] CHECK CONSTRAINT [FK_BookingPax_CabinClass_Min]
GO
ALTER TABLE [BookingPax]  WITH CHECK ADD  CONSTRAINT [FK_BookingPax_CabinClass_Pref] FOREIGN KEY([CabinClassPreferred])
REFERENCES [CabinClass] ([No])
GO
ALTER TABLE [BookingPax] CHECK CONSTRAINT [FK_BookingPax_CabinClass_Pref]
GO
ALTER TABLE [BookingPayment]  WITH CHECK ADD  CONSTRAINT [FK_BookingPayment_Booking] FOREIGN KEY([BookingId])
REFERENCES [Booking] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [BookingPayment] CHECK CONSTRAINT [FK_BookingPayment_Booking]
GO
ALTER TABLE [BookingQueue]  WITH CHECK ADD  CONSTRAINT [FK_BookingQueue_BookingCandidate] FOREIGN KEY([CandidateId])
REFERENCES [BookingCandidate] ([Id])
GO
ALTER TABLE [BookingQueue] CHECK CONSTRAINT [FK_BookingQueue_BookingCandidate]
GO
ALTER TABLE [DayBooking]  WITH CHECK ADD  CONSTRAINT [FK_DayBooking_DayBookingType] FOREIGN KEY([TypeId])
REFERENCES [DayBookingType] ([Id])
GO
ALTER TABLE [DayBooking] CHECK CONSTRAINT [FK_DayBooking_DayBookingType]
GO
ALTER TABLE [DayBooking]  WITH CHECK ADD  CONSTRAINT [FK_DayBooking_Event] FOREIGN KEY([EventId])
REFERENCES [Event] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [DayBooking] CHECK CONSTRAINT [FK_DayBooking_Event]
GO
ALTER TABLE [EventCabinClass]  WITH CHECK ADD  CONSTRAINT [FK_EventCabinClass_CabinClass] FOREIGN KEY([No])
REFERENCES [CabinClass] ([No])
GO
ALTER TABLE [EventCabinClass] CHECK CONSTRAINT [FK_EventCabinClass_CabinClass]
GO
ALTER TABLE [EventCabinClass]  WITH CHECK ADD  CONSTRAINT [FK_EventCabinClass_Event] FOREIGN KEY([EventId])
REFERENCES [Event] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [EventCabinClass] CHECK CONSTRAINT [FK_EventCabinClass_Event]
GO
ALTER TABLE [EventCabinClassDetail]  WITH CHECK ADD  CONSTRAINT [FK_EventCabinClassDetail_CabinClass] FOREIGN KEY([No])
REFERENCES [CabinClass] ([No])
GO
ALTER TABLE [EventCabinClassDetail] CHECK CONSTRAINT [FK_EventCabinClassDetail_CabinClass]
GO
ALTER TABLE [EventCabinClassDetail]  WITH CHECK ADD  CONSTRAINT [FK_EventCabinClassDetail_Event] FOREIGN KEY([EventId])
REFERENCES [Event] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [EventCabinClassDetail] CHECK CONSTRAINT [FK_EventCabinClassDetail_Event]
GO
ALTER TABLE [PostImage]  WITH CHECK ADD  CONSTRAINT [FK_PostImage_Post] FOREIGN KEY([PostId])
REFERENCES [Post] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [PostImage] CHECK CONSTRAINT [FK_PostImage_Post]
GO
