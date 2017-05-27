USE __DATABASE__
GO
/****** Object:  Table __SCHEMA__.[Booking]    Script Date: 2017-05-27 17:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE __SCHEMA__.[Booking](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[CruiseId] [uniqueidentifier] NOT NULL,
	[Reference] [nvarchar](8) NOT NULL,
	[FirstName] [nvarchar](64) NOT NULL,
	[LastName] [nvarchar](64) NOT NULL,
	[Email] [nvarchar](64) NOT NULL,
	[PhoneNo] [nvarchar](64) NOT NULL,
	[Lunch] [nvarchar](5) NOT NULL,
	[Discount] [tinyint] NOT NULL,
	[TotalPrice] [decimal](8, 2) NOT NULL,
	[IsLocked] [bit] NOT NULL,
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
/****** Object:  Table __SCHEMA__.[BookingCabin]    Script Date: 2017-05-27 17:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE __SCHEMA__.[BookingCabin](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[CruiseId] [uniqueidentifier] NOT NULL,
	[BookingId] [uniqueidentifier] NOT NULL,
	[CabinTypeId] [uniqueidentifier] NOT NULL,
	[Order] [tinyint] NOT NULL,
 CONSTRAINT [PK_BookingCabin] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table __SCHEMA__.[BookingPax]    Script Date: 2017-05-27 17:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE __SCHEMA__.[BookingPax](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[BookingCabinId] [uniqueidentifier] NOT NULL,
	[Group] [nvarchar](256) NOT NULL,
	[FirstName] [nvarchar](256) NOT NULL,
	[LastName] [nvarchar](256) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[Dob] [nchar](6) NOT NULL,
	[Nationality] [nchar](2) NOT NULL,
	[Years] [int] NOT NULL,
	[Order] [tinyint] NOT NULL,
 CONSTRAINT [PK_BookingPax] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table __SCHEMA__.[BookingPayment]    Script Date: 2017-05-27 17:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE __SCHEMA__.[BookingPayment](
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
/****** Object:  Table __SCHEMA__.[CabinType]    Script Date: 2017-05-27 17:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE __SCHEMA__.[CabinType](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Name] [nvarchar](16) NOT NULL,
	[Description] [nvarchar](2048) NOT NULL,
	[Capacity] [int] NOT NULL,
	[Order] [tinyint] NOT NULL,
 CONSTRAINT [PK_CabinType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table __SCHEMA__.[Cruise]    Script Date: 2017-05-27 17:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE __SCHEMA__.[Cruise](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[Name] [nvarchar](64) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsLocked] [bit] NOT NULL,
 CONSTRAINT [PK_Cruise] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table __SCHEMA__.[CruiseCabin]    Script Date: 2017-05-27 17:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE __SCHEMA__.[CruiseCabin](
	[CruiseId] [uniqueidentifier] NOT NULL,
	[CabinTypeId] [uniqueidentifier] NOT NULL,
	[Count] [int] NOT NULL,
	[PricePerPax] [decimal](8, 2) NOT NULL,
 CONSTRAINT [PK_CruiseCabin] PRIMARY KEY CLUSTERED 
(
	[CruiseId] ASC,
	[CabinTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table __SCHEMA__.[Log]    Script Date: 2017-05-27 17:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE __SCHEMA__.[Log](
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
/****** Object:  Table __SCHEMA__.[User]    Script Date: 2017-05-27 17:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE __SCHEMA__.[User](
	[Id] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[UserName] [nvarchar](16) NOT NULL,
	[PasswordHash] [nvarchar](1024) NOT NULL,
	[SecurityStamp] [nvarchar](1024) NOT NULL,
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
ALTER TABLE __SCHEMA__.[Booking] ADD  CONSTRAINT [DF_Booking_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE __SCHEMA__.[Booking] ADD  CONSTRAINT [DF_Booking_Discount]  DEFAULT ((0)) FOR [Discount]
GO
ALTER TABLE __SCHEMA__.[Booking] ADD  CONSTRAINT [DF_Booking_TotalPrice]  DEFAULT ((0)) FOR [TotalPrice]
GO
ALTER TABLE __SCHEMA__.[Booking] ADD  CONSTRAINT [DF_Booking_IsLocked]  DEFAULT ((0)) FOR [IsLocked]
GO
ALTER TABLE __SCHEMA__.[Booking] ADD  CONSTRAINT [DF_Booking_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE __SCHEMA__.[Booking] ADD  CONSTRAINT [DF_Booking_Updated]  DEFAULT (sysdatetime()) FOR [Updated]
GO
ALTER TABLE __SCHEMA__.[BookingCabin] ADD  CONSTRAINT [DF_BookingCabin_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE __SCHEMA__.[BookingPax] ADD  CONSTRAINT [DF_BookingPax_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE __SCHEMA__.[BookingPayment] ADD  CONSTRAINT [DF_BookingPayment_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE __SCHEMA__.[BookingPayment] ADD  CONSTRAINT [DF_BookingPayment_Created]  DEFAULT (sysdatetime()) FOR [Created]
GO
ALTER TABLE __SCHEMA__.[CabinType] ADD  CONSTRAINT [DF_CabinType_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE __SCHEMA__.[CabinType] ADD  CONSTRAINT [DF_CabinType_Order]  DEFAULT ((255)) FOR [Order]
GO
ALTER TABLE __SCHEMA__.[Cruise] ADD  CONSTRAINT [DF_Cruise_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE __SCHEMA__.[Cruise] ADD  CONSTRAINT [DF_Cruise_IsLocked]  DEFAULT ((0)) FOR [IsLocked]
GO
ALTER TABLE __SCHEMA__.[User] ADD  CONSTRAINT [DF_User_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE __SCHEMA__.[User] ADD  CONSTRAINT [DF_User_PasswordHash]  DEFAULT ('') FOR [PasswordHash]
GO
ALTER TABLE __SCHEMA__.[User] ADD  CONSTRAINT [DF_User_SecurityStamp]  DEFAULT ('') FOR [SecurityStamp]
GO
ALTER TABLE __SCHEMA__.[User] ADD  CONSTRAINT [DF_User_IsBooking]  DEFAULT ((0)) FOR [IsBooking]
GO
ALTER TABLE __SCHEMA__.[Booking]  WITH CHECK ADD  CONSTRAINT [FK_Booking_Cruise] FOREIGN KEY([CruiseId])
REFERENCES __SCHEMA__.[Cruise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE __SCHEMA__.[Booking] CHECK CONSTRAINT [FK_Booking_Cruise]
GO
ALTER TABLE __SCHEMA__.[BookingCabin]  WITH CHECK ADD  CONSTRAINT [FK_BookingCabin_Booking] FOREIGN KEY([BookingId])
REFERENCES __SCHEMA__.[Booking] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE __SCHEMA__.[BookingCabin] CHECK CONSTRAINT [FK_BookingCabin_Booking]
GO
ALTER TABLE __SCHEMA__.[BookingCabin]  WITH CHECK ADD  CONSTRAINT [FK_BookingCabin_CabinType] FOREIGN KEY([CabinTypeId])
REFERENCES __SCHEMA__.[CabinType] ([Id])
GO
ALTER TABLE __SCHEMA__.[BookingCabin] CHECK CONSTRAINT [FK_BookingCabin_CabinType]
GO
ALTER TABLE __SCHEMA__.[BookingCabin]  WITH CHECK ADD  CONSTRAINT [FK_BookingCabin_Cruise] FOREIGN KEY([CruiseId])
REFERENCES __SCHEMA__.[Cruise] ([Id])
GO
ALTER TABLE __SCHEMA__.[BookingCabin] CHECK CONSTRAINT [FK_BookingCabin_Cruise]
GO
ALTER TABLE __SCHEMA__.[BookingPax]  WITH CHECK ADD  CONSTRAINT [FK_BookingPax_BookingCabin] FOREIGN KEY([BookingCabinId])
REFERENCES __SCHEMA__.[BookingCabin] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE __SCHEMA__.[BookingPax] CHECK CONSTRAINT [FK_BookingPax_BookingCabin]
GO
ALTER TABLE __SCHEMA__.[BookingPayment]  WITH CHECK ADD  CONSTRAINT [FK_BookingPayment_Booking] FOREIGN KEY([BookingId])
REFERENCES __SCHEMA__.[Booking] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE __SCHEMA__.[BookingPayment] CHECK CONSTRAINT [FK_BookingPayment_Booking]
GO
ALTER TABLE __SCHEMA__.[CruiseCabin]  WITH CHECK ADD  CONSTRAINT [FK_CruiseCabin_CabinType] FOREIGN KEY([CabinTypeId])
REFERENCES __SCHEMA__.[CabinType] ([Id])
GO
ALTER TABLE __SCHEMA__.[CruiseCabin] CHECK CONSTRAINT [FK_CruiseCabin_CabinType]
GO
ALTER TABLE __SCHEMA__.[CruiseCabin]  WITH CHECK ADD  CONSTRAINT [FK_CruiseCabin_Cruise] FOREIGN KEY([CruiseId])
REFERENCES __SCHEMA__.[Cruise] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE __SCHEMA__.[CruiseCabin] CHECK CONSTRAINT [FK_CruiseCabin_Cruise]
GO
